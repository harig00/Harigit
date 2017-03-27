function varargout=gt2eustaticmm(massgt)
% [mmsea]=GT2EUSTATICMM(massgt)
%
% This function does the quick conversion between mass in Gt (e.g. ice mass
% loss from an ice sheet) and the equivalent eustatic sea level rise in
% millimeters.  
%
% INPUT:
%
% massgt     The mass in Gigatons that you want to convert.  Can be scalar
%            or vector.
%            
% OUTPUT:
%
% mmsea      The equivalent eustatic sea level rise in millimeters
%
% NOTES: Ocean surface area taken from ETOPO1 
%        http://www.ngdc.noaa.gov/mgg/global/etopo1_ocean_volumes.html
%        
% Last modified by charig-at-princeton.edu on 11/25/2015

defval('oceankm2',361900000);
defval('denwater',1000); %kg/m^3

% Go to si units
oceanm2 = oceankm2*1000*1000;
masskg = massgt*1e9*1000;

% Do it, and convert to mm
mmsea = masskg/oceanm2/denwater*1000;

% Output
varns={mmsea};
varargout=varns(1:nargout);
