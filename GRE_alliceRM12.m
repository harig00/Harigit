function varargout=GRE_alliceRM12(res,buf)  
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

if ~isstr(res) % Not a demo

  % The directory where you keep the base coordinates
  whereitsat=fullfile(getenv('IFILES'),'GLACIERS','RM2012');

  % Revert to original name if unbuffered
  if res==0 && buf==0
    fnpl=fullfile(whereitsat,'GRE_alliceRM12.mat');
  elseif buf==0;
    fnpl=fullfile(whereitsat,sprintf('%s-%i.mat','GRE_alliceRM12',res));
  elseif buf~=0
    fnpl=fullfile(whereitsat,sprintf('%s-%i-%g.mat','GRE_alliceRM12',res,buf));
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
          XY=GRE_alliceRM12(10);
          XYb=bezier(XY,round(res/10));
          XY=XYb;
        else
          XY=ellesmere(0);
          XYb=bezier(XY,res);
          XY=XYb;
        end
    end
  
    if buf ~=0
      % Check if we have this buffer already but only at base resolution, and then change
      % the res on that file (unlikely)
      fnpl2=fullfile(whereitsat,sprintf('%s-%i-%g.mat','GRE_alliceRM12',0,buf));
      if exist(fnpl2,'file')==2
          load(fnpl2)
          XYb=bezier(XY,res);
          XY=XYb;
      else
          % We make a new buffer
          disp('Buffering the coastlines... this may take a while');
          XY=GRE_alliceRM12(res);
          if buf > 0
             inout='outPlusInterior';
          else
             inout='in';
          end
          
          %%%
          % Greenland takes precendence in this area, so make it first
          %%%
          [LatB,LonB] = bufferm(XY(:,2),XY(:,1),buf,inout);
          % Periodize our way
          LonB(LonB<0) = LonB(LonB<0)+360;
          % Now subtract a nearby buffed version of Ellesmere
          if buf>1.0
              XY2 = ellesmere(10,buf-0.5);
          else
              XY2 = ellesmereg(10,0.5);
          end
          

          % Now subtract a smaller Ellesmere from Greenland
          % Note: Say you ask for buf=1.0.  Then we just made Greenland1.0
          % and we subtract from it Ellesmere0.5.  This is considered the
          % thing next door.  If we just subtracted a Greenland1.0, we
          % would lose large sections of Ellesmere.
          [x1,y1] = polybool('subtraction',LonB,LatB,XY2(:,1),XY2(:,2));
          
          XY = [x1 y1];
                

          

%     Maybe add this later, right now time is important
%           %%%
%           % Assembly complete!
%           %%%
%  
%           % Now we look at the new piece, and we know we must fix some edges
%           % where the things intersected.
%           hdl1=figure;
%           plot(x,y);
%           title('This plot is used to edit the coastlines.')
%     
%           fprintf(['The functions ELLESMERE has paused, and made a plot \n'...
%           ' of the current coastlines.  These should have some artifacts that \n'...
%           'you want to remove.  Here are the instructions to do that:\n \n'])
% 
%           fprintf(['DIRECTIONS:  Select the data points you want to remove with \n'...
%           'the brush tool.  Then right click and remove them.  After you have\n'...
%           ' finished removing the points you want, select the entire curve \n'...
%           'with the brush tool, and type return.  The program will save the \n'...
%           'currently brushed data in a variable, and then make another plot \n'...
%           'for you to confirm you did it right.\n'])
%           keyboard
%     
%           % Get the brushed data from the plot
%           pause(0.1);
%           hBrushLine = findall(hdl1,'tag','Brushing');
%           brushedData = get(hBrushLine, {'Xdata','Ydata'});
%           brushedIdx = ~isnan(brushedData{1});
%           brushedXData = brushedData{1}(brushedIdx);
%           brushedYData = brushedData{2}(brushedIdx);
%     
%           figure
%           plot(brushedXData,brushedYData)
%           title('This figure confirms the new data you selected with the brush.')
%     
%           fprintf(['The newest figure shows the data you selected with the brush \n'...
%           'tool after you finished editing.  If this is correct, type return.\n'...
%           '  If this is incorrect, type dbquit and run this program again to redo.\n'])
%           keyboard
%     
%           XY = [brushedXData' brushedYData'];  
  
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
  
  

