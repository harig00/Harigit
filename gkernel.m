function varargout=gkernel(TH,L,sord,long,statdyn)
% [K,r,th,N,V,MTAP]=GKERNEL(TH,L,sord,long,statdyn)
%
% Calculates a potential/geoid/gravity kernel for a polar cap
%
% INPUT:
%
% TH       Angular extent of the spherical cap, in degrees]
% L        Bandwidth (maximum angular degree)
% sord     1 Single polar cap of diameter TH [default]
%          2 Double polar cap of diameter TH
% long     Longitude of the cross section [degrees default:0]
%          OR if you give NaN then we will use xlm to show the unity
%          normalized functions
% statdyn  1 static kernel for ...
%          2 dynamic kernel for ...
%
% OUTPUT:
% 
% K        The potential/geoid/gravity kernel 
% r        The fractional radii (first dimension of K)
% th       The colatitude (second dimension of K)
% N        The Shannon number
% V        The eigenvalues of the concentration problem
% MTAP     The orders of the eigenfunctions - unique for caps
%
% Last modified by fjsimons-at-alum.mit.edu, 05/21/2013

defval('TH',60)

if ~isstr(TH)

  defval('L',16)
  defval('sord',1)
  defval('long',0)
  defval('th',linspace(0,pi,181)) % colatitude

  if isnan(long)
      fnpl=fullfile(getenv('IFILES'),'GKERNELS',...
		 sprintf('gkernel-%i-%i-%i-%s-%i.mat',...
			 TH,L,sord,'XLMs',statdyn));
  else
  fnpl=fullfile(getenv('IFILES'),'GKERNELS',...
		 sprintf('gkernel-%i-%i-%i-%i-%i.mat',...
			 TH,L,sord,long,statdyn));
  end

  if exist(fnpl,'file')==2
    load(fnpl)
  else
    % Load constants pertaining to the Earth
    GC=fralmanac('GravCst');
    R=fralmanac('Radius');
    % Fractional radius of the core-mantle boundary
    cmb=fralmanac('CMB')/R;
    
    % The fractional Earth radii at which you want to plot this
    r=linspace(cmb,1,100)';
    
    % Get the unit-normalized real spherical harmonics
    if length(long)==1 && isnan(long)
      [Y,th]=xlm([0 L],[],[],0,0);
      [~,~,~,~,~,~,~,dels]=addmon(L);
    else
      [Y,th,phi,dems,dels]=ylm(0:L,[],[],long*pi/180);
    end
    % This returns a (max(L)+1)^2 X length(th) array
    %[Y,th,phi,dems,dels]=ylm(0:L,[],[],long*pi/180);
    
    % If you want to check the whole-sphere, make G to eye, don't rely on
    % glmalpha to do this for you!
    if [TH==180 && sord==1] || [TH==90 && sord==2]
      G=eye((L+1)^2,(L+1)^2);
      V=ones((L+1)^2,1);
      N=(L+1)^2;
      [EM,EL,mz,blkm]=addmout(L);
      MTAP=EM;
    else
      % Get the Slepian coefficients for a single cap
      [G,V,EL,EM,N,GM2AL,MTAP]=glmalpha(TH,L,sord);
      % Better sort it with decreasing eigenvalue
      [V,i]=sort(V,'descend');
      % NOTE THAT THERE IS NO WAY TO GUARANTEE THAT THE ZONAL TAPER COMES
      % UP FIRST IF ALL EIGENVALUES ARE INDISTINGUISHABLE - WE CANNOT
      % COMPARE EIGENVALUE SEQUENCES BETWEEN GRUNBAUM EIGENVALUES...
      G=G(:,i); MTAP=MTAP(i);
    end

    % Check we're talking about the same thing
    % difer(dems-EM); difer(dels-EL)

    % The kernel is normalized by/in units of 4*pi*G/R
    % This is the sensitivity kernel for the potential anomaly at the surface
    % for density perturbations at depth
    K=nan(length(th),(L+1)^2,length(r));
    switch statdyn
        case 1
            for rind=1:length(r)
            Rl=repmat(r(rind).^dels./(2*dels+1),1,length(th));
            % This here has ROWS the colatitude COLUMNS the alpha
            K(:,:,rind)=(G'*[Y.*Rl])';
            end
        case 2
            % Now do Peter James' code
	        [~,Kl]=dyn_kernels([0:L],r,'isoviscous',0,'Earth',1);
            Kl(:,1)=1;
            indeks = gamini([0:L],[2*[0:L]+1]);
	        Rl=repmat([Kl(:,indeks+1)],1,length(th));
            for rind=1:length(r)
                temp=reshape(Rl(rind,:),size(Y));
                % This here has ROWS the colatitude COLUMNS the alpha
                K(:,:,rind)=(G'*[Y.*temp])';
                %keyboard
            end
        otherwise
	    error('Specify valid case')
    
      
    end
    % Make an array ROWS the radius COLUMNS the colatitude THIRD the alpha
    K=flipdim(shiftdim(K,2),1);
    % And go in order of increasing depth from the top down
    r=flipud(r(:));

    save(fnpl,'K','r','th','N','V','MTAP')
  end
  
  % Prepare output
  varns={K,r,th,N,V,MTAP};
  varargout=varns(1:nargout);
elseif strcmp(TH,'demo')
  defval('L',1)
  tind=L;
  % If 'demo', the second argument will be considered the taper index
  statdyn=2;
  [K,r,th,N,V,MTAP]=gkernel([],[],[],NaN,statdyn);
  % Transform spherical to Cartesian coordinates
  [TH,R]=meshgrid(th,r);
  Z=R.*cos(TH);
  X=R.*sin(TH);
  Z2=r.*cos(repmat(60*pi/180,1,length(r)))';
  X2=r.*sin(repmat(60*pi/180,1,length(r)))';
  
  %h1=figure
  clf
  ah1=krijetem(subnum(3,2));
  %Main top text
  axes('position',[0,0,1,1]);  % Define axes for the text.
  htext = text(.5,0.98,['Localized Dynamic Geoid Kernels L=30, TH=60'], 'FontSize', 12  );
  set(htext,'HorizontalAlignment','center');
  set(gca,'Visible','off');

  for tind=1:6
  axes(ah1(tind));
  Kplot=K(:,:,tind);
  % Black out the rest or not?
  % Kplot(Kplot<max(Kplot(:))/100)=NaN;
  % Strange but true
  pcolor([-X X],[-Z Z],[fliplr(Kplot) Kplot]); shading flat
  hold on
  plot(X2,Z2,'k-',-X2,Z2,'k-')
  %Make symmetric color bar with white in the middle 
  zfac=1;
  caxis(zfac*[-max(abs(Kplot(:))) max(abs(Kplot(:)))])
  kelicol
  axis image 
  colorbar
  title(['Alpha = ' num2str(tind)])
  end
  keyboard
else
  error('Specify right argument!')
end

