function varargout=ANT_AIS_RM12(res,buf)  
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
    fnpl=fullfile(whereitsat,'ANT_AIS_RM12.mat');
  elseif buf==0;
    fnpl=fullfile(whereitsat,sprintf('%s-%i.mat','ANT_AIS_RM12',res));
  elseif buf~=0
    fnpl=fullfile(whereitsat,sprintf('%s-%i-%g.mat','ANT_AIS_RM12',res,buf));
  end

  % If you already have a file
  if exist(fnpl,'file')==2 
    load(fnpl)
    if nargout==0
      plot(XY(:,1),XY(:,2),'k-'); axis equal; grid on
    else
      % Prepare Output
      varns={XY,lonc,latc};
      varargout=varns(1:nargout);
    end
  else
    % You are about to make a file
    % Do we buffer? Not here, so do it regular
    if buf==0
        if res>10
          % Load 10 and go from there because 10 is closer to the original 
          XY=ANT_AIS_RM12(10);
          XYb=bezier(XY,round(res/10));
          XY=XYb;
        else
          XY=ANT_AIS_RM12(0);
          XYb=bezier(XY,res);
          XY=XYb;
        end
    end
  
    if buf ~=0
      % Check if we have this buffer already but only at base resolution, and then change
      % the res on that file (unlikely)
      fnpl2=fullfile(whereitsat,sprintf('%s-%i-%g.mat','ANT_AIS_RM12',0,buf));
      if exist(fnpl2,'file')==2
          load(fnpl2)
          XYb=bezier(XY,res);
          XY=XYb;
      else
          % We make a new buffer
          disp('Buffering the coastlines... this may take a while');
          XY=ANT_AIS_RM12(res);
          if buf > 0
             inout='outPlusInterior';
          else
             inout='in';
          end
          
          %%%
          % Make eantarctica first
          %%%
          %[LatB,LonB] = bufferm(XYw(:,2),XYw(:,1),buf,inout);
          % Periodize our way
          %LonB(LonB<0) = LonB(LonB<0)+360;
          
    
              [LatB,LonB] = bufferm(XY(:,2),XY(:,1),buf,inout);
        
                

              
          % Check to see if the first or last point is now NaN, because
          % this will not work then when we go to make the kernel.
          if isnan(LonB(1)) 
              LonB = LonB(2:end);
              LatB = LatB(2:end);
          elseif isnan(LonB(end))
              LonB = LonB(1:end-1);
              LatB = LatB(1:end-1);
          end

          
          XY = [LonB LatB];  
  
          % We rotate back to the south? [default: no]
          %if rotb==1
          %   [thetap,phip,rotmats]=rottp((90-XY(:,2))*pi/180,XY(:,1)/180*pi,lonc,latc*pi/180,0);
          %   XY = [phip*180/pi 90-thetap*180/pi];
          %end

          % Periodize our way
          %lon=XY(:,1);
          %lat=XY(:,2);
          %lon(lon<0) = lon(lon<0)+360;
          %XY = [lon lat];

    
      end % end if fnpl2 exist
    
    end % end if buf>0
   
    % Save the file
    save(fnpl,'XY')
    % Prepare Output
    varns={XY,lonc,latc};
    varargout=varns(1:nargout);
  
  end % end if fnpl exist
  
elseif strcmp(res,'rotated')
    % Return a 1 flag as output, indicating the region is a rotated region
    varargout={1};
  
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
  
  

