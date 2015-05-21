function varargout=eantarcticaCoasts1OceanBuf(res,buf,rotb)  
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
% Last modified by charig at princeton.edu, 02/02/2014

defval('res',0)
defval('buf',0)
defval('rotb',0)
defval('lonc',0)
defval('latc',-90)

% The directory where you keep the coordinates
whereitsat=fullfile(getenv('IFILES'),'COASTS');

% Revert to original name if unbuffered
if res==0 && buf==0
  fnpl=fullfile(whereitsat,'EantarcticaCoasts1.mat');
elseif buf==0;
  fnpl=fullfile(whereitsat,sprintf('%s-%i.mat','EantarcticaCoasts1',res));
elseif buf~=0
  fnpl=fullfile(whereitsat,sprintf('%s-%i-%g.mat','EantarcticaCoasts1OceanBuf',res,buf));
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
  % We know here, that buf should be greater than zero
  
  % Check if we have this buffer already but only at base resolution, and then change
  % the res on that file
  fnpl2=fullfile(whereitsat,sprintf('%s-%i-%g.mat','EantarcticaCoasts1OceanBuf',0,buf));
  if exist(fnpl2,'file')==2
      load(fnpl2)
      XYb=bezier(XY,res);
      XY=XYb;
  else
  
    % We need to do a new buffer size 
    if buf > 0
      inout='out';
    else
      inout='in';
    end
   
    % First we get the proper buffer for the region
    XYe1 = eantarcticaCoasts1(res,buf,0);

    % Get the original Interior region
    XYeInt = eantarcticaIntG(0,0,0);
    
    % Now subtract this region
    [x,y] = polybool('subtraction',XYe1(:,1),XYe1(:,2),XYeInt(:,1),XYeInt(:,2));   
    
    % Also subtract out the buffered version of coasts2
    XYe2 = eantarcticaCoasts2OceanBuf(0,buf,0);
    [x,y] = polybool('subtraction',x,y,XYe2(:,1),XYe2(:,2));   
    
    
    % A figure for test 
%     figure
%     plot(x2,y2)
%     axis equal
%     hold on
%     plot(XYp(:,1),XYp(:,2),'r')


    % Now we look at the new piece, and we know we must fix some edges
    hdl1=figure;
    plot(x,y);
    title('This plot is used to edit the coastlines.')
    

    disp(['The functions PANTARCTICAOCEANBUF has paused, and made a plot'...
    ' of the current coastlines.  These should have some artifacts that '...
    'you want to remove.  Here are the instructions to do that:'])

    disp(['DIRECTIONS:  Select the data points you want to remove with '...
        'the brush tool.  Then right click and remove them.  After you have'...
        ' finished removing the points you want, select the entire curve '...
        'with the brush tool, and type return.  The program will save the '...
        'currently brushed data in a variable, and then make another plot '...
        'for you to confirm you did it right.'])
   
    keyboard
    
    % Get the brushed data from the plot
    pause(0.1);
    hBrushLine = findall(hdl1,'tag','Brushing');
    brushedData = get(hBrushLine, {'Xdata','Ydata'});
    brushedIdx = ~isnan(brushedData{1});
    brushedXData = brushedData{1}(brushedIdx);
    brushedYData = brushedData{2}(brushedIdx);
    
    figure
    plot(brushedXData,brushedYData)
    title('This figure confirms the new data you selected with the brush.')
    
    disp(['The newest figure shows the data you selected with the brush '...
        'tool after you finished editing.  If this is correct, type return.'...
        '  If this is incorrect, type dbquit and run this program again to redo.'])
    keyboard
    
   XY = [brushedXData' brushedYData'];

    % We rotate back to the south? [default: no]
    if rotb==1
        [thetap,phip,rotmats]=rottp((90-XY(:,2))*pi/180,XY(:,1)/180*pi,lonc,latc*pi/180,0);
        XY = [phip*180/pi 90-thetap*180/pi];
    end

  end

  % Save the file
  save(fnpl,'XY')
  
end
  
  varns={XY,lonc,latc};
  varargout=varns(1:nargout);
end
  

