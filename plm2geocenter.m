function [XYZt,thedates]=plm2geocenter(plmt)
% [plmt,thedates]=GEOCENTER2PLM(XYZ)
%
% Converts geocenter vectors in mm to spherical harmonic coefficients 
% C10, C11, S11.  Geocenter vectors are the X Y Z components in mm of the
% vector from the origin of the Center of Figure Frame to the instantaneous
% mass center of the Earth.
% 
% This function will work on either XYZ components that you give it, or on
% a file that you downloaded from CSR Texas and removed the header.
%
% INPUT:
%
% XYZ           An array of X Y Z components for the geocenter vector [X Y Z] (mm)
%                OR a matrix where each row is one vector (i.e. X is column
%                 vector) (mm)
%                OR a string which is the name of a file you got from CSR
%                Texas. Note: you must remove the header from such a file
%                so it can be loaded directly as a matrix.
%
% OUTPUT:
%
% plmt          Matrix listing l,m,cosine and sine coefficients.  This is a
%                 3 dimension matrix, with the same format as grace2plmt.
%                 If you gave one vector, you get one set of coefficients.
%                 If you gave multiple vectors, the first dimension is the
%                 indicie and the second and third [i,1:2,:] would be a
%                 lmcosi style matrix.
% thedates      In the case in which you gave it a file from CSR, then this
%                 will hold the dates of the time series
% plmterr       Same as plmt, but if you gave it a file from CSR then this 
%                 will contain the uncertainties on the SH coefficients.
%
%
% See also 
%
% Last modified by charig-at-princeton.edu, 06/18/2014

defval('XYZ',[1 1 1])

% Top level directory
% For Chris
IFILES=getenv('IFILES');
% For FJS, who has a different $IFILES
%IFILES='/u/charig/Data/';

if ~isstr(plmt)
    % Its a vector, so do it.
    a=fralmanac('Radius','Earth');
    
    if ndims(plmt)==2
        C10 = plmt(1,3);
        C11 = plmt(2,3);
        S11 = plmt(2,4);
    elseif ndims(plmt)==3
        C10 = plmt(:,1,3);
        C11 = plmt(:,2,3);
        S11 = plmt(:,2,4);        
    end

    % Convert to vector in mm
    X = C11*a*sqrt(3)*1000;
    Y = S11*a*sqrt(3)*1000;
    Z = C10*a*sqrt(3)*1000;
    XYZt = [X Y Z];

    
    defval('thedates',length(X))
    
    % Collect output
    varns={XYZt,thedates};
    varargout=varns(1:nargout);
  

elseif exist(plmt,'file')==2
    % We have a file from to operate on, do it.
    deg1 = load(XYZ);
    [n,m] = size(deg1);

    % The first column is dates
    % Convert the dates to Matlab format
    deg1(:,1)=datenum([deg1(:,1) ones(n,1) ones(n,1)]);

    XYZ = deg1(:,2:4);
    XYZerr = deg1(:,5:7);
    
    % Do it
    [plmt]=geocenter2plm(XYZ);
    % Also do the error
    [plmterr]=geocenter2plm(XYZerr);
    
    thedates = deg1(:,1);
    
    % Collect output
    varns={plmt,thedates,plmterr};
    varargout=varns(1:nargout);

    
elseif strcmp(plmt,'demo1')
    % A demo!
    % Compare against the Deg1 from Swenson et al. 2008
    
    % Load SLR values
    deg1 = load(fullfile(IFILES,'SLR','GCN_RL05_NH.txt'));
    [n,m] = size(deg1);
    % The first column is dates
    % Convert the dates to Matlab format
    deg1(:,1)=datenum([deg1(:,1) ones(n,1) ones(n,1)]);
    XYZ = deg1(:,2:4);
    XYZerr = deg1(:,5:7);
    thedates=deg1(:,1);
    
    % Load Swenson values
    deg1_swe=load(fullfile(IFILES,'GRACE','deg1_RL05_NH.txt'));
    [n,m] = size(deg1_swe);
    dates_str = num2str(deg1_swe(:,1));
    deg1dates = datenum([str2num(dates_str(:,1:4)) str2num(dates_str(:,5:6)) 15*ones(n,1)]);
    [b,m] = unique(deg1dates);
    deg1dates = deg1dates(m);
    for i=1:n/2; temp = [deg1_swe(2*i-1,2:7); deg1_swe(2*i,2:7)]; mydeg1(i,:,:) = temp; end;
    
    sweXYZt = plm2geocenter(mydeg1);
    
    [potcoffs,thedatesgac] = graceGAC2plmt('CSR','RL05','POT',0);
    potcoffs=potcoffs(:,2:3,:);
    
    gacXYZt = plm2geocenter(potcoffs);
    
    ZZ=interp1(thedates,XYZ(:,3),thedatesgac(5:end));
    XX=interp1(thedates,XYZ(:,1),thedatesgac(5:end));
    YY=interp1(thedates,XYZ(:,2),thedatesgac(5:end));
    ZZ=ZZ-mean(ZZ(1:end-1));
    
    keyboard
    
    figure
    ah1=krijetem(subnum(3,1));
    
    axes(ah1(1));
    plot(thedates,XYZ(:,3),'b-')
    hold on
    plot(deg1dates,sweXYZt(:,3),'k-')
    datetick('x',28)
    ylabel('Diatance (mm)')
    title('Geocenter Z Component')
    
    axes(ah1(2));
    plot(thedatesgac(5:end),ZZ-gacXYZt(5:end,3)','b-')
    hold on
    plot(deg1dates,sweXYZt(:,3),'k-')
    datetick('x',28)
    ylabel('Diatance (mm)')
    title('Geocenter Z Component')
    
    
else
    error('GEOCENTER2PLM: Your string was not matched.')
    
end
    



