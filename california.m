function varargout=california(res,buf)  
% XY=CALIFORNIA(res,buf)
% CALIFORNIA(...) % Only makes a plot
%
% Returns the coordinates of glaciers in the 
% northern part of the Gulf of Alaska 
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
% Last modified by charig at princeton.edu, 04/14/2014

defval('res',0)
defval('buf',0)

if ~isstr(res)

% The directory where you keep the coordinates
whereitsat=fullfile(getenv('IFILES'),'COASTS');

% Revert to original name if unbuffered
if res==0 && buf==0
  fnpl=fullfile(whereitsat,'California.mat');
elseif buf==0;
  fnpl=fullfile(whereitsat,sprintf('%s-%i.mat','California',res));
elseif buf~=0
  fnpl=fullfile(whereitsat,sprintf('%s-%i-%g.mat','California',res,buf));
end

% If you already have a file
if exist(fnpl,'file')==2 
  load(fnpl)
  if nargout==0
    %plot(XY(:,1),XY(:,2),'k-'); axis equal; grid on
  else
    varns={XY};
    varargout=varns(1:nargout);
  end
else
  % You are about to make a file
  if res==0
    % First part %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %clf
    load(fullfile(getenv('IFILES'),'COASTS','California.mat'));
    % We've already checked this file when we made it that it is correct
 
    %plot(XY(:,1),XY(:,2),'LineW',2,'Color','k');
       
  else
    XY=california(0);
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
    
    [latcells,loncells]=polysplit(LatB,LonB);
    
    for p = 1:length(loncells)
        theareas(p) = spharea([loncells{p} latcells{p}]);
    end
    LonB = loncells{theareas==max(theareas)};
    LatB = latcells{theareas==max(theareas)};
    
    % Periodize our way
    LonB(LonB<0) = LonB(LonB<0)+360;
    XY = [LonB LatB];
        
    % A figure for test 
%     figure
%     plot(LonB,LatB)
%     axis equal
  
   end
   
  % Save the file
  save(fnpl,'XY')
  
  varns={XY};
  varargout=varns(1:nargout);
  
end
  
elseif strcmp(res,'demo1')
      path(path,'~/src/m_map');
  
end
  
  
end
