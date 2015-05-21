function varargout=xyz2XYZ(dom,sclfac,method) 
% [XY_scl,xy,XY]=XYZ2XYZ(dom,sclfac,method)
%
% xyz2XYZ reads in spherical coordinates of a region and scales the region
% by a factor.  This is accomplished by performing a stereographic 
% projection, then a dilation in the plane, and then projection back 
% to the spherical domain.
%
% INPUT:
%
% dom       A string name with an approved region such as 'africa', OR
% XY        its spherical coordinates (such as supplied from 'africa' etc), OR
%
% sclfac    The factor you want to scale the region by
% method    How to do the scaling:
%           0 sclfac is the amount of the Euclidian dilation performed (default)
%           1 sclfac is instead the increase in area you want of the region. 
%             In this case the proceedure is iterative, since the relationship
%             between dilation and change in area is region specific to do 
%             the projection scaling.
%
%
% OUTPUT:
%
% XY_scl    The new scaled coordinates of the region
% xy        The Euclidean coordinates of the original region (i.e. Stereographically projected)
% XY        The spherical coordinates of the original region
%
% EXAMPLE:
%
% xyz2XYZ('demo1')   Increase the area of Australia by 50% and make some
%                    plots of it
%
% SEE ALSO:
%
% Map Projections - A Working Manual, USGS Professional Paper 1395, John P.
% Snyder
%
% Last modified by charig-at-princeton.edu, 02/17/2011


defval('dom','greenland')
defval('sclfac',1.5)
defval('method',1)

if ~strcmp(dom,'demo1')

% Get the coordinates
if isstr(dom)
  % Specify the region by name
  defval('pars',10);
  eval(sprintf('XY=%s(%i);',dom,pars));
else
  % Specify the region by the coordinates of the bounding curve
  XY=dom;
end

if method==0
% Method 0, where you know the scaling you want

% Find the center of the projection
[lonc,latc] = rcenter(XY);
% Other projection info
R=1.0;
knot=1.0;

% Convert everything to radians
loncR = lonc*pi/180;
latcR = latc*pi/180;
XYR = [XY(:,1)*pi/180 XY(:,2)*pi/180];

% Do Stereographic projection
k = 2*knot./(1 + sin(latcR)*sin(XYR(:,2)) + cos(latcR)*cos(XYR(:,2)).*cos(XYR(:,1) - loncR));

x = R*k.*cos(XYR(:,2)).*sin(XYR(:,1) - loncR);

y = R*k.*(cos(latcR)*sin(XYR(:,2)) - sin(latcR)*cos(XYR(:,2)).*cos(XYR(:,1) - loncR));

% Do the dilation
x = x*sclfac;
y = y*sclfac;

% Project back onto the sphere
p = (x.^2 + y.^2).^0.5;

c = 2*atan(p/2/R/knot);
%latitude
YR_scl = asin(cos(c)*sin(latcR) + (y.*sin(c).*cos(latcR)./p));
%longitude
XR_scl = loncR + atan2(x.*sin(c),(p.*cos(latcR).*cos(c) - y.*sin(latcR).*sin(c)));


% Back to degrees
XY_scl = [XR_scl*180/pi YR_scl*180/pi];

elseif method==1
    % Method 1, where you know what increase in area you want
    
    % Find the center of the projection
    [lonc,latc] = rcenter(XY);
    % Other projection info
    R=1.0;
    knot=1.0;

    % Convert everything to radians
    loncR = lonc*pi/180;
    latcR = latc*pi/180;
    XYR = [XY(:,1)*pi/180 XY(:,2)*pi/180];

    % Project to the plane
    k = 2*knot./(1 + sin(latcR)*sin(XYR(:,2)) + cos(latcR)*cos(XYR(:,2)).*cos(XYR(:,1) - loncR));

    x = R*k.*cos(XYR(:,2)).*sin(XYR(:,1) - loncR);

    y = R*k.*(cos(latcR)*sin(XYR(:,2)) - sin(latcR)*cos(XYR(:,2)).*cos(XYR(:,1) - loncR));
    
    % Make a guess at the scale factor needed for the increase in area
    Mfac = sqrt(sclfac);
    areanew=spharea(XY);
    areaold=areanew;
    tol=0.01;
    iter=0;
    
    % Iterate to the proper area (Usually only 2 or 3 iterations necessary)
    while (abs((sclfac-areanew)/(sclfac*areaold)) > tol) & iter<10
        % Do the dilation
        xtest = x*Mfac;
        ytest = y*Mfac;
        
        % Project back to the sphere
        p = (xtest.^2 + ytest.^2).^0.5;

        c = 2*atan(p/2/R/knot);
        %latitude
        YR_scl = asin(cos(c)*sin(latcR) + (ytest.*sin(c).*cos(latcR)./p));
        %longitude
        XR_scl = loncR + atan2(xtest.*sin(c),(p.*cos(latcR).*cos(c) - ytest.*sin(latcR).*sin(c)));
        % Back to degrees
        XY_scl = [XR_scl*180/pi YR_scl*180/pi];
        
        % Update the area of this 
        areanew=spharea(XY_scl)/areaold;
        
        % Print feedback
        disp(strcat('Iteration: ',num2str(iter)));
        disp(strcat('New area: ',num2str(areanew),'   Mfac to get this area: ',num2str(Mfac)));

        % Guess what we would need as our next Mfac, and subtract that from
        % what we used, so we can do it again if necessary
        Mfac = Mfac * sqrt(sclfac/areanew);
        
        iter = iter+1;
                
    end
    
end
    
% Provide output where requested
varns={XY_scl,[x y],XY};
varargout=varns(1:nargout);

elseif strcmp(dom,'demo1')
    % Increase the area of Australia by 50% and make some plots of it
    [XY_scl,xy,XY]=xyz2XYZ('australia',1.5,1);
    figure
    plot(XY_scl(:,1),XY_scl(:,2),XY(:,1)-360,XY(:,2))
end


