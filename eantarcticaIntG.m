function varargout=eantarcticaIntG(res,buf,rotb)  
% XY=EANTARCTICAINTG(res,buf,rotb)
% EANTARCTICAINTG(...) % Only makes a plot
%
% Finds the coordinates of East Antarctica's interior 
%
% INPUT:
%
% res      0 The standard, default values
%          N Splined values at N times the resolution
% buf      The region buffer you want
% rotb     0 You want the coordinates on the equator for mathematical 
%            operations (e.g. you need to make a kernel) [default]
%          1 You want the coordinates rotated back to their original
%            location (e.g. for plotting)
%
% OUTPUT:
%
% XY       Closed-curved coordinates of the continent
% lonc     The amount of rotation around the z axis that these coordinates
%           have been rotated by. (Needed for reverse rotation)
% latc     The amount of rotation around the z axis that these coordinates
%           have been rotated by. (Needed for reverse rotation)
%
% Note: EANTARCTICA returns the coordinates of East Antarctica after they
% have been rotated to the equator, so that they can be fed into KERNELC
% without problems.  This is simply a rotation of 90 degrees around y.
% The function GLMALPHA should return the correct eigenfunctions, having
% rotated the G matrix back to the pole.
%
% Last modified by charig at princeton.edu, 07/02/2013

defval('res',0)
defval('buf',0)
defval('lonc',0)
defval('latc',-90)
defval('rotb',0)

% The directory where you keep the coordinates
whereitsat=fullfile(getenv('IFILES'),'COASTS');

% Revert to original name if unbuffered
if res==0 && buf==0
  fnpl=fullfile(whereitsat,'EantarcticaIntG.mat');
elseif buf==0;
  fnpl=fullfile(whereitsat,sprintf('%s-%i.mat','EantarcticaIntG',res));
elseif buf~=0
  fnpl=fullfile(whereitsat,sprintf('%s-%i-%g.mat','EantarcticaIntG',res,buf));
end

% If you already have a file
if exist(fnpl,'file')==2 
  load(fnpl)
  if rotb==1
      [thetap,phip,rotmats]=rottp((90-XY(:,2))*pi/180,XY(:,1)/180*pi,lonc,latc*pi/180,0);
      XY = [phip*180/pi 90-thetap*180/pi];
  end
  if nargout==0
    plot(XY(:,1),XY(:,2),'k-'); axis equal; grid on
  else
    varns={XY,lonc,latc};
    varargout=varns(1:nargout);
  end
else
  % You are about to make a file
  load(fullfile(whereitsat,'EantarcticaIntG.mat'))
  if res==0
      % Do nothing, this is a good start
  else
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
    
    % Now we can buffer this. Note that BUFFERM has gone through quite 
    % a few revisions. The cell output is no longer supported these days
    [LatB,LonB] = bufferm(XY(:,2),XY(:,1),abs(buf),inout);
    
    % Note that, if due to BEZIER there might be a pinched-off loop in
    % the XY you will get an extra NaN and will need to watch it
    % If this shouldn't work, keep it all unchanged in other words
    try
      % You'll need a line for every possible version behavior
      % Note how POLY2CW has disappeared from BUFFERM
      if sign(buf)<0 || ~isempty(strfind(version,'2010a')) 
	% Take the last bit of non-NaNs; there might have been pinched
        % off sections in the original
	  LonB=LonB(indeks(find(isnan(LonB)),1)+1:indeks(find(isnan(LonB)),2));
	  LatB=LatB(indeks(find(isnan(LatB)),1)+1:indeks(find(isnan(LatB)),2));
      elseif ~isempty(strfind(version,'2011a')) || ~isempty(strfind(version,'2012a'))
	  LonB=LonB(1:find(isnan(LonB))-1);
	  LatB=LatB(1:find(isnan(LatB))-1);
      end
    catch
      disp('BUFFERM failed to buffer as expected')
    end
    
    % Definitely get rid of the NaNs again? Should be overkill at this point
    %XY=XY(~isnan(XY(:,1)) & ~isnan(XY(:,2)),:);
    
    XY = [LonB LatB];
  
   end
  
   
  % Save the file
  save(fnpl,'XY')
  
  % Do we return rotated coordinates?
  if rotb==1
      [thetap,phip,rotmats]=rottp((90-XY(:,2))*pi/180,XY(:,1)/180*pi,-lonc*pi/180,latc*pi/180,0);
      XY = [phip*180/pi 90-thetap*180/pi];
  end
  
  
  varns={XY,lonc,latc};
  varargout=varns(1:nargout);
end
