function varargout=baffin(res,buf)  
% XY=WANTARCTICAG(res,buf)
% WANTARCTICAG(...) % Only makes a plot
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

if ~isstr(res)

% The directory where you keep the coordinates
whereitsat=fullfile(getenv('IFILES'),'GLACIERS','RGI_3_2');

% Revert to original name if unbuffered
if res==0 && buf==0
  fnpl=fullfile(whereitsat,'Baffin.mat');
elseif buf==0;
  fnpl=fullfile(whereitsat,sprintf('%s-%i.mat','Baffin',res));
elseif buf~=0
  fnpl=fullfile(whereitsat,sprintf('%s-%i-%g.mat','Baffin',res,buf));
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
    load(fullfile(getenv('IFILES'),'Glaciers','RGI_3_2','Baffin.mat'));
    % We've already checked this file when we made it that it is correct
 
    %plot(XY(:,1),XY(:,2),'LineW',2,'Color','k');
       
  else
    XY=baffin(0);
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
	  LonB=LonB(indeks(find(isnan(LonB)),'end')+1:end);
	  LatB=LatB(indeks(find(isnan(LatB)),'end')+1:end);
      elseif ~isempty(strfind(version,'2011a')) || ~isempty(strfind(version,'2012a'))
	  LonB=LonB(1:find(isnan(LonB))-1);
	  LatB=LatB(1:find(isnan(LatB))-1);
      end
    catch
      disp('BUFFERM failed to buffer as expected')
    end
    
    
    % Periodize our way
    LonB(LonB<0) = LonB(LonB<0)+360;
    
    XY = [LonB LatB];
  
   end
  
   
  % Save the file
  save(fnpl,'XY')
  
  varns={XY};
  varargout=varns(1:nargout);
  
end
  
elseif strcmp(res,'demo')
      path(path,'~/src/m_map');
      XY1 = baffin(10);
      XY2 = baffin(10,0.5);
      figure
      m_proj('oblique mercator','longitudes',[318 318],'latitudes',[90 50],'aspect',1.0);
      m_grid;
      m_coast('color','k');
      % Original
      m_line(XY1(:,1),XY1(:,2),'color','magenta','linestyle','-');
      % Buffered
      m_line(XY2(:,1),XY2(:,2),'color','blue','linestyle','-');
      XY3=ellesmere(10,0.5);
      m_line(XY3(:,1),XY3(:,2),'color','green','linestyle','-');
  
end
  
  
end
