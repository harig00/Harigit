function varargout=ANT_pantarcticaRM12(res,buf)  
% XY=ELLESMEREG(res,buf)
% 
% Finds the coordinates of Ellesmere Island, taking into account
% the fact that it is next to Greenland and Baffin Island, which 
% causes problems when you buffer.
%
% INPUT:
%
% res      0 The standard, default values
%          N Splined values at N times the resolution
% buf      Distance in degrees that the region outline will be enlarged
%          by BUFFERM, not necessarily integer, possibly negative
%          [default: 0]
%
% OUTPUT:
%
% XY       Closed-curved coordinates that result from this process
%
% NOTES: We start with a region outline created by encircling glaciers in
% the Randolph Glacier Inventory 3.2 (http://www.glims.org/RGI/). This
% outline is buffered as requested.  Since buffered regions infringe on
% neighboring regions, we subtract the outlines for Greenland and Baffin
% Island. This can cause some artifacts near some of the boundary
% intersections, so this function employs the same brushing technique as the
% basin functions for Antarctica. We make the region, plot it, remove
% erroneous points using the brushing tool, and save this new outline.
%
% Last modified by charig at princeton.edu, 09/04/2014
% Last modified by fjsimons-at-alum.mit.edu, 09/23/2014

defval('res',10)
defval('buf',0)
defval('lonc',0)
defval('latc',-90)
defval('rotb',1)


if ~isstr(res) % Not a demo

  % The directory where you keep the base coordinates
  whereitsat=fullfile(getenv('IFILES'),'GLACIERS','RM2012');

  % Revert to original name if unbuffered
  if res==0 && buf==0
    fnpl=fullfile(whereitsat,'ANT_pantarcticaRM12.mat');
  elseif buf==0;
    fnpl=fullfile(whereitsat,sprintf('%s-%i.mat','ANT_pantarcticaRM12',res));
  elseif buf~=0
    fnpl=fullfile(whereitsat,sprintf('%s-%i-%g.mat','ANT_pantarcticaRM12',res,buf));
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
    % Do we buffer? Not here, so do it regular
    if buf==0
        if res>10
          % Load 10 and go from there because 10 is closer to the original 
          XY=ANT_pantarcticaRM12(10);
          XYb=bezier(XY,round(res/10));
          XY=XYb;
        else
          XY=ANT_pantarcticaRM12(0);
          XYb=bezier(XY,res);
          XY=XYb;
        end
    end
  
    if buf ~=0
      % Check if we have this buffer already but only at base resolution, and then change
      % the res on that file (unlikely)
      fnpl2=fullfile(whereitsat,sprintf('%s-%i-%g.mat','ANT_pantarcticaRM12',0,buf));
      if exist(fnpl2,'file')==2
          load(fnpl2)
          XYb=bezier(XY,res);
          XY=XYb;
      else
          % We make a new buffer
          disp('Buffering the coastlines... this may take a while');
          XYp=ANT_pantarcticaRM12(res);
          if buf > 0
             inout='outPlusInterior';
          else
             inout='in';
          end
          
          %%%
          % Make wantarctica first
          %%%
          %[LatB,LonB] = bufferm(XYw(:,2),XYw(:,1),buf,inout);
          % Periodize our way
          %LonB(LonB<0) = LonB(LonB<0)+360;
          
          % Need to rotate pantarctica to the equator
    % Convert to Cartesian coordinates
    [X,Y,Z]=sph2cart(XYp(:,1)*pi/180,XYp(:,2)*pi/180,1);
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
    XYp = [lon lat];
    
              [LatB,LonB] = bufferm(XYp(:,2),XYp(:,1),buf,inout);
              
    % Get the original Wantarctica region
    % But remember to rotate to the equator
    XYw = ANT_wantarcticaRM12(10);
    [X,Y,Z]=sph2cart(XYw(:,1)*pi/180,XYw(:,2)*pi/180,1);
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
    XYw = [lon lat];
    
 
          % Now subtract these regions
          [x1,y1] = polybool('subtraction',LonB,LatB,XYw(:,1),XYw(:,2));
          
          XY = [x1 y1];
                

          

          %%%
          % Assembly complete!
          %%%
 
          % Now we look at the new piece, and we know we must fix some edges
          % where the things intersected.
          hdl1=figure;
          plot(x1,y1);
          title('This plot is used to edit the coastlines.')
    
          fprintf(['The functions ELLESMERE has paused, and made a plot \n'...
          ' of the current coastlines.  These should have some artifacts that \n'...
          'you want to remove.  Here are the instructions to do that:\n \n'])

          fprintf(['DIRECTIONS:  Select the data points you want to remove with \n'...
          'the brush tool.  Then right click and remove them.  After you have\n'...
          ' finished removing the points you want, type dbcont.  The program will save the \n'...
          'remaining data in a variable, and then make another plot \n'...
          'for you to confirm you did it right.\n'])
          keyboard
          
          b = findobj(hdl1,'Type','Line');
          % Make sure they are closed, this also handily removes duplicate NaNs
          [x,y]=closePolygonParts(b.XData,b.YData);
          
          %brushidx = logical(b.BrushData);
          %brushedXData = b.XData(brushidx);
          %brushedYData = b.YData(brushidx);
          % Get the brushed data from the plot
%           pause(0.1);
%           hBrushLine = findall(hdl1,'tag','Brushing');
%           brushedData = get(hBrushLine, {'Xdata','Ydata'});
%           brushedIdx = ~isnan(brushedData{1});
%           brushedXData = brushedData{1}(brushedIdx);
%           brushedYData = brushedData{2}(brushedIdx);
    
          figure
          plot(x,y)
          title('This figure confirms the new data you selected with the brush.')
    
          fprintf(['The newest figure shows the data you selected with the brush \n'...
          'tool after you finished editing.  If this is correct, type dbcont.\n'...
          '  If this is incorrect, type dbquit and run this program again to redo.\n'])
          keyboard
    
          XY = [x' y'];  
  
          % We rotate back to the south? [default: yes]
          if rotb==1
             [thetap,phip,rotmats]=rottp((90-XY(:,2))*pi/180,XY(:,1)/180*pi,lonc,latc*pi/180,0);
             XY = [phip*180/pi 90-thetap*180/pi];
          end

          % Periodize our way
          lon=XY(:,1);
          lat=XY(:,2);
          lon(lon<0) = lon(lon<0)+360;
          XY = [lon lat];

    
      end % end if fnpl2 exist
    
    end % end if buf>0
   
    % Save the file
    save(fnpl,'XY')
    % Output
    varns={XY};
    varargout=varns(1:nargout);
  
  end % end if fnpl exist
  
elseif strcmp(res,'demomake')
      % This demo illustrates the proper order that is needed to make these
      % coordinate files, since there are dependancies.
      % The coordinates need to be created in order of increasing buffer,
      % and ellesmere before baffin
      
    
elseif strcmp(res,'demo1')
      path(path,'~/src/m_map');
      XY1 = ellesmere(10);
      XY2 = ellesmere(10,0.2);
      XY3 = greenland(1,0.5);
      figure
      m_proj('oblique mercator','longitudes',[318 318],'latitudes',[90 50],'aspect',1.0);
      m_grid;
      m_coast('color','k');
      % Original
      m_line(XY1(:,1),XY1(:,2),'color','magenta','linestyle','-');
      % Buffered
      m_line(XY2(:,1),XY2(:,2),'color','blue','linestyle','-');
      m_line(XY3(:,1),XY3(:,2),'color','green','linestyle','-');
      
  
end
  
  

