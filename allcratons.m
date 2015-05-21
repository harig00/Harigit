function varargout=allcratons(res,scal)  
% XY=ORINOCO(res,scal)
% ORINOCO(...) % Only makes a plot
%
% Finds the coordinates of the Orinoco basin 
%
% INPUT:
%
% res      0 The standard, default values
%          N Splined values at N times the resolution
% scal     Scale this to something else
%
% OUTPUT:
%
% XY       Closed-curved coordinates of the continent
%
% Last modified by fjsimons-at-alum.mit.edu, 08/27/2009

defval('res',0)
defval('scal',0)
if res==0
  fnpl=fullfile(getenv('IFILES'),'COASTS','allcratons.mat');
else
  fnpl=fullfile(getenv('IFILES'),'COASTS',...
		sprintf('allcratons.mat',res));
end

if exist(fnpl,'file')==2 
  load(fnpl)
  if scal~=0
    XY(:,1)=scale(XY(:,1),[200 330]);
    XY(:,2)=scale(XY(:,2),[46 -70]);
  end
  if nargout==0
    plot(XY(:,1),XY(:,2),'k-'); axis equal; grid on
    axis([260 345 -60 15])
  else
    varns={XY};
    varargout=varns(1:nargout);
  end
else
  if res==0
    % First part %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    clf
    XY=load(fullfile(getenv('IFILES'),'COASTS','allcratons'));
    % Get rid of common NaNs
    XY=XY(~isnan(XY(:,1)) & ~isnan(XY(:,2)),:);
 
    % Now make sure the distances aren't huge
    xx=XY(:,1); yy=XY(:,2); 
    d=sqrt((xx(2:end)-xx(1:end-1)).^2+(yy(2:end)-yy(1:end-1)).^2);
    dlev=3;
    p=find(d>dlev*nanmean(d));
    nx=insert(xx,NaN,p+1);
    ny=insert(yy,NaN,p+1);
    XY=[nx(:) ny(:)];
    
    % Note this is already a closed contour

    plot(XY(:,1),XY(:,2),'LineW',2,'Color','k');
    
    axis equal 
    axis([260 345 -60 15])
    
    % Check this out %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    hold on
    for index=1:length(XY)
      pm(index)=plot(XY(index,1),XY(index,2),'o');
      set(pm(index),'MarkerE','k','MarkerF',[1 1 1]*(index-1)/length(XY))
      title(num2str(index))
      pause(0.02)
    end
    % Check this out %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %eval(sprintf('save %s XY',fnpl))
    save(fnpl,'XY')
  else
    XY=allcratons(0);
    %XYb=bezier(XY,res);
    %XY=XYb;
    %eval(sprintf('save %s XY',fnpl))
    save(fnpl,'XY')
  end
  varns={XY};
  varargout=varns(1:nargout);
end
