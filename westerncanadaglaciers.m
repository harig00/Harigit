function varargout=westerncanadaglaciers(res,buf)  
% XY=GULFOFALASKAN(res,buf)
% GULFOFALASKAN(...) % Only makes a plot
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
% Last modified by charig at princeton.edu, 04/04/2014

defval('res',0)
defval('buf',0)

if ~isstr(res)

% The directory where you keep the coordinates
whereitsat=fullfile(getenv('IFILES'),'GLACIERS','RGI_3_2');

% Revert to original name if unbuffered
if res==0 && buf==0
  fnpl=fullfile(whereitsat,'westerncanadaglaciers.mat');
elseif buf==0;
  fnpl=fullfile(whereitsat,sprintf('%s-%i.mat','westerncanadaglaciers',res));
elseif buf~=0
  fnpl=fullfile(whereitsat,sprintf('%s-%i-%g.mat','westerncanadaglaciers',res,buf));
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
  load(fullfile(getenv('IFILES'),'GLACIERS','RGI_3_2','westerncanadaglaciers.mat'));
  % We've already checked this file when we made it that it is correct
  
  [latcells,loncells]=polysplit(XY(:,2),XY(:,1));
  XY = [loncells latcells];
  
  if res~=0
      for p = 1:length(loncells)
          XYb{p}=bezier([loncells{p} latcells{p}],res);
          XY{p,1} = XYb{p}(:,1);
          XY{p,2} = XYb{p}(:,2);
      end
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
    
    
    for p = 1:length(loncells)
       [LatB,LonB] = bufferm(XY{p,2},XY{p,1},abs(buf),inout);
       [latcells2,loncells2]=polysplit(LatB,LonB);
       for h = 1:length(loncells2)
           theareas(h) = spharea([loncells2{h} latcells2{h}]);
       end
       LonB = loncells2{theareas==max(theareas)};
       LatB = latcells2{theareas==max(theareas)};
       % Periodize our way
       LonB(LonB<0) = LonB(LonB<0)+360;
       XY{p,2} = LatB;
       XY{p,1} = LonB;
    end
  
    % If you buffered a lot you might need to join these pieces together
    [x,y] = polybool('union',XY{1,1},XY{1,2},XY{2,1},XY{2,2});
    for p = 3:length(loncells)
        [x,y] = polybool('union',x,y,XY{p,1},XY{p,2});
    end
    XY = {x y};
    
    end % if buffer
    
    % Rejoin the polygons
    [lat,lon] = polyjoin(XY(:,2),XY(:,1));
    
    XY = [lon lat];
    

  % Save the file
  save(fnpl,'XY')
  
  varns={XY};
  varargout=varns(1:nargout);
   
end

  
elseif strcmp(res,'demo1')
      path(path,'~/src/m_map');
      XY1 = gulfofalaskaN(10);
      XY2 = gulfofalaskaN(10,0.5);
      figure
      m_proj('oblique mercator','longitudes',[220 220],'latitudes',[75 50],'aspect',1.0);
      m_grid;
      m_coast('color','k');
      % Original
      m_line(XY1(:,1),XY1(:,2),'color','magenta','linestyle','-');
      % Buffered
      m_line(XY2(:,1),XY2(:,2),'color','blue','linestyle','-');
      
elseif strcmp(res,'demo2')
      path(path,'~/src/m_map');
      XY1 = gulfofalaskaN(10);
      XY2 = gulfofalaskaS(10);
      figure
      m_proj('oblique mercator','longitudes',[220 220],'latitudes',[75 50],'aspect',1.0);
      m_grid;
      m_coast('color','k');
      % Original
      m_line(XY1(:,1),XY1(:,2),'color','magenta','linestyle','-');
      % Buffered
      m_line(XY2(:,1),XY2(:,2),'color','blue','linestyle','-');
  
end
  
  
end
