function varargout=checkregions(params,res)
% XY=CHECKREGIONS(region)
%
% This program checks if you have a specific region calculated already
% for a set of parameters.
%
% INPUT:
% 
% params     Either a string of the region you are looking for, such as
%            'namerica', or a cell if you are also looking for a buffer,
%            such as {'greenland' 0.5}.
%
% res        The boundary resolution you are looking for. Default is 10.
%          
%
% OUTPUT:
%
% yesno      A 0 or 1 depending on if the coordinates exist.
%
% maxbuffer   If you ask for this output, it will return the largest buffer
%             that currently exists for this region.
% 
% SEE ALSO: ls2cell
%     
% Last modified by charig-at-princeton.edu, 10/26/2015


defval('res','10');
defval('yesno',0);
defval('buf',[]);
defval('maxbuffer',[]);
if buf==0; buf=[]; end
if isnumeric(res); res=num2str(res); end
if ischar(params); regn=params;
else iscell(params); regn=params{1}; buf=num2str(params{2}); end


% Assemble the region name string from the params we were given
if isempty(buf)
   myfile = [upper(regn(1)) regn(2:end) '-' res '.mat'];
else
   myfile = [upper(regn(1)) regn(2:end) '-' res '-' buf '.mat'];
end

% If we want to know the max buffer
if nargout>=2
   myfile2 = [upper(regn(1)) regn(2:end) '-' res '-*.mat'];
end
   

% Here are the main paths where we store coordinates. Paths end in "filesep"
% You should change these as needed!
mypaths = {fullfile(getenv('IFILES'),'COASTS',filesep) ...
           fullfile(getenv('IFILES'),'GLACIERS','RGI_3_2','REGIONS',filesep)};
          

% Now get the file names in these directories, and compare
% 'dir' does not work for cells, so use a for loop. Can use a while if 
% you have lots of directories
for i=1:length(mypaths)
   cls = ls2cell(mypaths{i});

   % Compare to our file
   yesno = yesno + sum(strcmpi(cls,myfile));
   
   % Again, here we want max buffer
   if nargout>=2 
       % Use a try statement here because what we are looking for might not
       % exist in every path we search.
       try
          wehave = ls2cell([mypaths{i} myfile2]);
          maxbuffer=max(cell2mat(cellfun(@(x)...
              str2double(x(length([regn '-' res '-'])+1:end-4)),...
              wehave, 'UniformOutput', false)));
       end 
   end
   
end

if isempty(maxbuffer)
    disp('CHECKREGIONS found no buffers for the region you seek.')
end

% Collect output
varns={yesno,maxbuffer};
% Provide output where requested
varargout=varns(1:nargout);
    
    
