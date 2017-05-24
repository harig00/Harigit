function varargout=exportboundaries(regions,savedir)  
% exportboundaries(varargin)
% 
% Export coordinates to a ascii file.  Useful if you want to use them in GMT.
%
% INPUT:
%
% regions     A cell array input list where each input is the name of
%             a region whos coordinates you want to output to ascii.  You
%             can use any of the regular format (i.e. string or cell) e.g.:
%             'greenland'
%             {{'greenland' 0.5}}
%             {{'greenland' 0.5} {'greenland' 1}} 
%             {{'greenland' 0.5} 'greenland'} 
% savedir     Give alternate save location. Directories end with "filesep".
%             Default save location is in current working directory.
%
% OUTPUT:
%
% XY       Closed-curved coordinates of the continent
%
%
% Note: At the moment, this does not work for regions that require
% additional parameters, such as Antarctica.  It will return the default
% for Antarctica, but if you would like the rotated version, more changes
% are needed.
%
% Last modified by charig at princeton.edu, 09/03/2014

defval('regions',{'greenland' 0.5});
%defval('regions',{{'greenland' 0.5} {'greenland' 1}});
defval('pars',10);
defval('savedir',[]);


for i=1:length(regions)
    dom=regions{i};
    
    if isstr(dom)
        % If it's a named geographical region (+buffer?) or a coordinate boundary
        % Run the named function to return the coordinates
        XY=eval(sprintf('%s(%i)',dom,pars));	
        fnpl1=sprintf('REGION-%s-%i.dat',dom,pars);
    elseif iscell(dom)
        % We have a cell, with a buffer
        buf=dom{2};
        XY=eval(sprintf('%s(%i,%f)',dom{1},pars,buf));
        fnpl1=sprintf('REGION-%s-%i-%g.dat',dom{1},pars,buf);
    else
        % You just have coordinates already
	    XY=dom;
        fnpl1=sprintf('REGION-yourXYcoordinates-%i.dat',round(cputime));
    end
    
    if exist(savedir)
        fnpl1 = [savedir fnpl1];
    end
    
    % Now do some output
    fp1 = fopen(fnpl1,'wt');
    fprintf(fp1,'%.4e %.4e \n',XY');
    fclose(fp1);


end


