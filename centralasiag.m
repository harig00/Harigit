function varargout=centralasiag(res,buf)  
% XY=PAMIRG(res,buf)
% 
% Returns the coordinates of the Pamir region, which was
% created from locations of glaciers within the region.
% It takes into account neighboring regions, which 
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
% neighboring regions, we subtract the outlines for neighboring regions.
% This can cause some artifacts near some of the boundary
% intersections, so this function employs the same brushing technique as the
% basin functions for Antarctica. We make the region, plot it, remove
% erroneous points using the brushing tool, and save this new outline.
%
% Not the best solution, but the best I have found so far.
%
% Last modified by charig at princeton.edu, 10/23/2015

defval('res',0)
defval('buf',0)

if ~isstr(res) % Not a demo

  % The directory where you keep the base coordinates
  whereitsat=fullfile(getenv('IFILES'),'GLACIERS','RGI_3_2','REGIONS');

  % Revert to original name if unbuffered
  if res==0 && buf==0
    fnpl=fullfile(whereitsat,'CentralAsiag.mat');
  elseif buf==0;
    fnpl=fullfile(whereitsat,sprintf('%s-%i.mat','CentralAsiag',res));
  elseif buf~=0
    fnpl=fullfile(whereitsat,sprintf('%s-%i-%g.mat','CentralAsiag',res,buf));
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
        if res==0
          % First part 
          load(fullfile(whereitsat,'CentralAsiag.mat'));
          % We've already checked this file when we made it that it is correct
          % It was made using
%           xy1=tibetqiliang(0);
%           xy2=himalayag(0);
%           xy3=pamirg(0);
%           xy4=tienshang(0);
%           XY = [xy1; NaN NaN; xy2; NaN NaN; xy3; NaN NaN; xy4];
%           [LATOUT,LONOUT,cerr,tol] = reducem(XY(:,2),XY(:,1));
%           [lat,lon] = interpm(LATOUT,LONOUT,0.5);
%           XY=[lon lat];
%           save('~/Data/GLACIERS/RGI_3_2/REGIONS/CentralAsiag.mat','XY')
          % I need to go back through and reduce the density of the other
          % polygons
          % so this is not necessary. Otherwise it takes too long to do the
          % buffering
        else
          XY=centralasiag(0);
          XYb=bezier(XY,res);
          XY=XYb;
        end
    end
  
    if buf ~=0
      % Check if we have this buffer already but only at base resolution, and then change
      % the res on that file
      fnpl2=fullfile(whereitsat,sprintf('%s-%i-%g.mat','CentralAsiag',0,buf));
      if exist(fnpl2,'file')==2
          load(fnpl2)
          XYb=bezier(XY,res);
          XY=XYb;
      else
          % We make a new buffer
          disp('Buffering the coastlines... this may take a while');
          XY=centralasiag(res);
          if buf > 0
             inout='outPlusInterior';
          else
             inout='in';
          end
          
          % Make it
          [LatB,LonB] = bufferm(XY(:,2),XY(:,1),buf,inout);
          XY = [LonB LatB];
  
      end % end if fnpl2 exist
    
    end % end if buf>0
   
    % Save the file
    save(fnpl,'XY')
    % Output
    varns={XY};
    varargout=varns(1:nargout);
  
  end % end if fnpl exist
  
elseif strcmp(res,'demo1')
      % demo    
  
end
  
  

