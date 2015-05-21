function varargout=wantarctica(res,buf)  
% XY=WANTARCTICA(res,buf)
% WANTARCTICA(...) % Only makes a plot
%
% Finds the coordinates of West Antarctica 
%
% INPUT:
%
% res      0 The standard, default values
%          N Splined values at N times the resolution
% buf      The region buffer you want
%
% OUTPUT:
%
% XY       Closed-curved coordinates of the continent
%
% Last modified by charig at princeton.edu, 02/05/2013

defval('res',0)
defval('buf',0)

% The directory where you keep the coordinates
whereitsat=fullfile(getenv('IFILES'),'COASTS');

% Revert to original name if unbuffered
if res==0 && buf==0
  fnpl=fullfile(whereitsat,'Wantarctica.mat');
elseif buf==0;
  fnpl=fullfile(whereitsat,sprintf('%s-%i.mat','Wantarctica',res));
elseif buf~=0
  fnpl=fullfile(whereitsat,sprintf('%s-%i-%g.mat','Wantarctica',res,buf));
end

% If you already have a file
if exist(fnpl,'file')==2 
  load(fnpl)
  if nargout==0
    plot(XY(:,1),XY(:,2),'k-'); axis equal; grid on
  else
    varns={XY};
    varargout=varns(1:nargout);
  end
else
  % You are about to make a file
  if res==0
    % First part %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    clf
    load(fullfile(getenv('IFILES'),'COASTS','Wantarctica.mat'));
    % We've already checked this file when we made it that it is correct
 
    %plot(XY(:,1),XY(:,2),'LineW',2,'Color','k');
       
  else
    XY=wantarctica(0);
    XYb=bezier(XY,res);
    XY=XYb;
  end
  
  % Do we buffer?
   if buf ~= 0
    if buf > 0
      inout='out';
    else
      inout='in';
    end
    % Make some buffered coordinates and save them for later use
    disp('Buffering the coastlines... this may take a while');
    
    % In order to buffer properly we need to rotate to the equator so that
    % we are on a single hemisphere bookkeeping wise... (i.e. not 
    % crossing the dateline)
    
    % Find the geographical center and the area
    [lonc,latc,A]=rcenter([XY(:,1) XY(:,2)]);
    % Convert to Cartesian coordinates
    [X,Y,Z]=sph2cart(XY(:,1)*pi/180,XY(:,2)*pi/180,1);
    [Xc,Yc,Zc]=sph2cart(lonc*pi/180,latc*pi/180,1);
   
    % Apply the rotation to put it on the equator
    xyzp=[roty(-latc*pi/180)*rotz(lonc*pi/180)*[X(:) Y(:) Z(:)]']';
    xyzc=[roty(-latc*pi/180)*rotz(lonc*pi/180)*[Xc   Yc   Zc  ]']';
    % See LOCALIZATION and KLMLMP2ROT for the counterrotation
    % Transform back to spherical coordinates
    [phi,piminth,r]=cart2sph(xyzp(:,1),xyzp(:,2),xyzp(:,3));
    lon=phi*180/pi; lat=piminth*180/pi;
    [phic,piminthc]=cart2sph(xyzc(1),xyzc(2),xyzc(3));
    loncp=phic*180/pi; latcp=piminthc*180/pi;
    % Now we can buffer this. Note that BUFFERM has gone through quite 
    % a few revisions. The cell output is no longer supported these days
    [LatB,LonB] = bufferm(lat,lon,abs(buf),inout);
    
    % Note that, if due to BEZIER there might be a pinched-off loop in
    % the XY you will get an extra NaN and will need to watch it
    % If this shouldn't work, keep it all unchanged in other words
    try
      % You'll need a line for every possible version behavior
      % Note how POLY2CW has disappeared from BUFFERM
      if sign(buf)<0 || ~isempty(strfind(version,'2010a')) 
	% Take the last bit of non-NaNs; there might have been pinched
        % off sections in the original
	  LonB=LonB(indeks(find(isnan(LonB)),'end')+1:end);
	  LatB=LatB(indeks(find(isnan(LatB)),'end')+1:end);
      elseif ~isempty(strfind(version,'2011a')) || ~isempty(strfind(version,'2012a'))
	  LonB=LonB(1:find(isnan(LonB))-1);
	  LatB=LatB(1:find(isnan(LatB))-1);
      end
    catch
      disp('BUFFERM failed to buffer as expected')
    end
    
    % Definitely get rid of the NaNs again? Should be overkill at this point
    %XY=XY(~isnan(XY(:,1)) & ~isnan(XY(:,2)),:);
    
    % Now that we have buffered we rotate back to the original place
     % Convert to Cartesian coordinates
    [X,Y,Z]=sph2cart(LonB*pi/180,LatB*pi/180,1);
   
    % Apply the NEGATIVE rotation IN THE REVERSE ORDER to put it back
    xyzp=[rotz(-lonc*pi/180)*roty(latc*pi/180)*[X(:) Y(:) Z(:)]']';
    xyzc=[rotz(-lonc*pi/180)*roty(latc*pi/180)*[xyzc(1) xyzc(2) xyzc(3)]']';
    % See LOCALIZATION and KLMLMP2ROT for the counterrotation
    % Transform back to spherical coordinates
    [phi,piminth,r]=cart2sph(xyzp(:,1),xyzp(:,2),xyzp(:,3));
    lon=phi*180/pi; lat=piminth*180/pi;
    [phic,piminthc]=cart2sph(xyzc(1),xyzc(2),xyzc(3));
    loncp=phic*180/pi; latcp=piminthc*180/pi;
    % Check that this rotation put the center back where it was
    difer(loncp-lonc); difer(latcp-latc);
    % Periodize our way
    lon(lon<0) = lon(lon<0)+360;
    
    XY = [lon lat];
  
   end
  
   
  % Save the file
  save(fnpl,'XY')
  
  varns={XY};
  varargout=varns(1:nargout);
end
