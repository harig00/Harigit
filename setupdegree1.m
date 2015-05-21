function varargout=setupdegree1(thedates,product)
% [deg1array]=SETUPDEGREE1(thedates,product)
%
% This program will load degree one data from a product of your choice, and
% match it to a series of dates belonging to perhaps GRACE data.
%
%
% INPUT:
% 
% thedates     The dates of the midpoint of the GRACE data.
% product      The degree 1 data product that you want. Can be 
%                [default: 'Swenson08'] or 'SLR'
%
% OUTPUT:
% 
% deg1array    A three dimensional matrix of the degree one terms for your dates
%
%
% NOTE:
%    Both degree one data products can be found here: 
%      http://gracetellus.jpl.nasa.gov/data/degree1/
%
%
% Last modified by charig-at-princeton.edu, 07/02/2014


% Supply defaults
defval('product','Swenson08')
    
if strcmp(product,'Swenson08')
      % Load Swenson values
      deg1=load(fullfile(getenv('IFILES'),'GRACE','deg1_RL05_NH.txt'));
      [n,m] = size(deg1);
      % The time window is in columns 8 and 9
      monthstart = num2str(deg1(1:2:end,8));
      monthend = num2str(deg1(1:2:end,9));
      monthstart = datenum([str2num(monthstart(:,1:4)) str2num(monthstart(:,5:6)) str2num(monthstart(:,7:8))]);
      monthend = datenum([str2num(monthend(:,1:4)) str2num(monthend(:,5:6)) str2num(monthend(:,7:8))]);
      monthmid = (monthstart+monthend)/2;
      for i=1:n/2; temp = [deg1(2*i-1,2:7); deg1(2*i,2:7)]; mydeg1(i,:,:) = temp; end;
    
elseif strcmp(product,'SLR')
      % Load SLR values
      deg1 = load(fullfile(getenv('IFILES'),'SLR','GCN_RL05_NH.txt'));
      [n,m] = size(deg1);
      % The time window is in columns 8 and 9
      monthstart = num2str(deg1(1:2:end,8));
      monthend = num2str(deg1(1:2:end,9));
      monthstart = datenum([str2num(monthstart(:,1:4)) str2num(monthstart(:,5:6)) str2num(monthstart(:,7:8))]);
      monthend = datenum([str2num(monthend(:,1:4)) str2num(monthend(:,5:6)) str2num(monthend(:,7:8))]);
      monthmid = (monthstart+monthend)/2;
      % Then we want columns 2,3,4 but we need to convert them to plm
      % because they are in xyz
      XYZ = deg1(:,2:4);
      XYZerr = deg1(:,5:7);
      plmt=geocenter2plm(XYZ);
      plmterr=geocenter2plm(XYZerr);
      plmt(:,:,5:6) = plmterr(:,:,3:4);
      mydeg1 = plmt;
      
end
  
% Now we want to select only the degree one terms for where we have GRACE data    
for j = 1:length(thedates)
    where1=thedates(j)>monthstart & thedates(j)<monthend;
    if ~any(where1)
        % If there is no Deg1 value within our specific interval, 
        % don't change anything, because we know the first few months are missing
        disp('No change to degree 1')
        deg1array(j,:,:) = [1 0 0 0 0 0; 1 1 0 0 0 0];
    elseif length(find(where1~=0))>1
        % There are two degree one months that can fit this grace data, so
        % pick the one closest
        temp1 = find(where1~=0);
        temp2 = monthmid(where1) - thedates(j);
        indeks = temp1(temp2==min(abs(temp2)));
        disp(['Deg1 value for ' datestr(monthmid(indeks)) ' used.']);
        deg1array(j,:,:) = mydeg1(indeks,:,:);
    else
        disp(['Deg1 value for ' datestr(monthmid(where1)) ' used.']);
        deg1array(j,:,:) = mydeg1(where1,:,:);
    end
end


% Collect output
varns={deg1array};
varargout=varns(1:nargout);