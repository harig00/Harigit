function slmcosi_filt = gaussian_filter(slmcosi_region,Ltrunc,r)
% slmcosi = GAUSSIAN_FILTER(region, Ltrunc, r)
%
% Applies Gaussian smoothing filter according to Wahr, '98.
%
% INPUT:
%
% region            Gridded data of binary mask
% Ltrunc            Spherical harmonic degree of truncation
% r                 Half width in km
%
% OUTPUT:
%
% slmcosi_filt      Smoothed region in slmcosi form
%
%
% Last modified by mgsterenborg-at-post.harvard.edu, 01/13/2012

%r is half width (km)

%[slmcosi_region, dw] = xyz2plm(region, Ltrunc);

a=6378;
half_width = (r/a);
b = log(2)/(1 - cos(half_width));
W=zeros(Ltrunc+1,2);
W(:,1)=(0:Ltrunc)'; 
W(1,2)=1/(2*pi);    %W0
W(2,2)=1/(2*pi)*(((1+exp(-2*b))/(1-exp(-2*b)))-(1/b));  %W1
L=1;
for mm=3:length(W)
    W(mm,2) = (-((2*L + 1)/b)*W(L+1,2))+W((L+1)-1,2);  %W2
    L=L+1;
end

% for mm=3:length(W)
%     W(mm,2) = (-((2*(mm-2)+1)/b)*W(mm-1,2))+W(mm-2,2);  %W2
% end

slmcosi_filt = zeros(length(slmcosi_region),4);
slmcosi_filt(:,1:2) = slmcosi_region(:,1:2);


for mm=1:length(slmcosi_filt)
    for jj=1:length(W)
        if slmcosi_filt(mm,1) == W(jj,1)
            slmcosi_filt(mm,3)=2*pi*W(jj,2).*slmcosi_region(mm,3);
            slmcosi_filt(mm,4)=2*pi*W(jj,2).*slmcosi_region(mm,4);
            break
        end
    end
end

% figure(3)
% plot(W(:,1),2*pi*W(:,2))

chek = 0;



