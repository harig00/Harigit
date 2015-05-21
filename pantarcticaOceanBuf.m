function varargout=pantarcticaOceanBuf(res,buf,rotb)  
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
defval('rotb',1)
defval('lonc',0)
defval('latc',-90)

% The directory where you keep the coordinates
whereitsat=fullfile(getenv('IFILES'),'COASTS');

% Revert to original name if unbuffered
if res==0 && buf==0
  fnpl=fullfile(whereitsat,'Pantarctica.mat');
elseif buf==0;
  fnpl=fullfile(whereitsat,sprintf('%s-%i.mat','Pantarctica',res));
elseif buf~=0
  fnpl=fullfile(whereitsat,sprintf('%s-%i-%g.mat','PantarcticaOceanBuf',res,buf));
  % This function only deal with buffered stuff
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
  % We know here, that buf should be greater than zero
  
  % Check if we have this buffer already but only at base resolution, and then change
  % the res on that file
  fnpl2=fullfile(whereitsat,sprintf('%s-%i-%g.mat','PantarcticaOceanBuf',0,buf));
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
   
    % First we get the zero buffer for West Antarctica
    XYw = wantarcticaG(res,0);
    % Need to rotate wantarctica to the equator
    % Convert to Cartesian coordinates
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

    % Get a buffered Pantarctica
    % Note: we can use this here because nearly the whole thing is
    % coastline and it only borders 1 region
    XYp = pantarctica(res,buf); 
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

    % Now subtract these regions 
    [x,y] = polybool('subtraction',XYp(:,1),XYp(:,2),XYw(:,1),XYw(:,2));
    
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
  end

  % Save the file
  save(fnpl,'XY')
  
end
  
  varns={XY};
  varargout=varns(1:nargout);
end
