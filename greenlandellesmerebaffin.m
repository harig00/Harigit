function varargout=greenlandellesmerebaffin(res,buf)  
% XY=GREENLANDELLESMEREBAFFIN(res,buf)
%
% Finds the coordinates of a combined region for Greenland, Ellesmere
% Island, and Baffin Island.
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
% Last modified by charig at princeton.edu, 09/04/2014

defval('res',0)
defval('buf',0)

if ~isstr(res)

  XYg = greenland(res,buf);
  XYe = ellesmere(res,buf);
  XYb = baffin(res,buf);

  [X,Y] = polybool('union',XYg(:,1),XYg(:,2),XYe(:,1),XYe(:,2));
  [X,Y] = polybool('union',X,Y,XYb(:,1),XYb(:,2));

  if find(isnan(X))
    X=X(1:find(isnan(X))-1);
    Y=Y(1:find(isnan(Y))-1);
  end

  XY = [X Y];

  varns={XY};
  varargout=varns(1:nargout);
  
elseif strcmp(res,'demo')
      path(path,'~/src/m_map');
      XY1 = greenlandellesmerebaffin(10,0.5);
      figure
      m_proj('oblique mercator','longitudes',[318 318],'latitudes',[90 50],'aspect',1.0);
      m_grid;
      m_coast('color','k');
      % Original
      m_line(XY1(:,1),XY1(:,2),'color','magenta','linestyle','-');
  
end
  

