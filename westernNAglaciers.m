function varargout=gulfofalaskaN(res,buf)  
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
  fnpl=fullfile(whereitsat,'westernNAglaciers.mat');
elseif buf==0;
  fnpl=fullfile(whereitsat,sprintf('%s-%i.mat','westernNAglaciers',res));
elseif buf~=0
  fnpl=fullfile(whereitsat,sprintf('%s-%i-%g.mat','westernNAglaciers',res,buf));
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
  
    
    XY1=westerncanadaglaciers(res,buf);
    XY2=gulfofalaskaNS(res,buf);
    
    [x,y] = polybool('union',XY1(:,1),XY1(:,2),XY2(:,1),XY2(:,2));

    % Periodize our way
    x(x<0) = x(x<0)+360;
    
    XY = [x y];
    
%     % A figure for test 
%     figure
%     plot(x,y)
%      
%      keyboard
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
