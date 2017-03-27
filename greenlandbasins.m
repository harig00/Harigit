function varargout=greenlandbasins(res,buf)   
% XY=GREENLAND(res,buf,nearby)
% GREENLAND(...) % Only makes a plot
%
% Finds the coordinates of Greenland, potentially buffered by some amount.
%
% INPUT:
%
% basin
% buf      Distance in degrees that the region outline will be enlarged
%          by BUFFERM, not necessarily integer, possibly negative
%          [default: 0]
% nearby   Subtract the nearby islands of Ellesmere and Baffin
%          from your coordinates [default: 1] or 0
%
% OUTPUT:
%
% XY       Closed-curved coordinates of the continent
%
% Last modified by charig-at-princeton.edu, 09/29/2015


defval('basin','1to8')
defval('buf',0.5)
defval('res',10)


%fnpl=sprintf('%s/%s%s.mat',fullfile(getenv('IFILES'),'COASTS'),'GreenlandB',basin);
fnpl=sprintf('%s/%s%s.mat',fullfile(getenv('IFILES'),'COASTS'),'GreenlandB1to8-0-','0.5');
load(fnpl)

%disp('Buffering...')
%[LatB,LonB]=bufferm(XY(:,2),XY(:,1),abs(buf),'outplusinterior');

% Periodize the right way
%XY=[LonB+360*any(LonB<0) LatB];
    
%XY=[LonB LatB];
%keyboard
%  save('~/Data/COASTS/GreenlandB1to8-0-0.5.mat','XY')
  varns={XY};
  varargout=varns(1:nargout);








