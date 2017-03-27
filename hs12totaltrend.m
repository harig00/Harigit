function hs12totaltrend
%
% Here we plot the fit to the total time series of mass change
%
% Last modified by charig at princeton.edu on 03/18/2016

defval('L',60);
defval('Pcenter','CSRRL05');
defval('TH',{'greenland' 0.5});
dom=TH{1};
XYbuffer=TH{2};

% Get the GRACE coefficients, projected into the basis we want
[slept,~,thedates,TH,G,CC,V,N]=grace2slept(Pcenter,dom,XYbuffer,60,[],[],[],[],'SD',1);
[dems,dels,mz,lmcosi,mzi,mzo,bigm,bigl,rinm,ronm,demin] = addmon(L);


% How much of the data do you want to fit?
defval('nmonths',length(thedates));
%nmonths=71;
% Clip this to this length
%thedates = thedates(1:nmonths);
%slept = slept(1:nmonths,:);

% Do the correction for GIA
% FYI, PGRt is referenced to the first date
[thedates,PGRt]=correct4pgr(thedates,'Paulson07',{dom XYbuffer},60);
sleptcorrected = slept - PGRt;


% Fit "signal" to the corrected Slepian coefficients
%[ESTsignal,ESTresid,ftests,extravalues,total,alphavarall,totalparams, ...
%     totalparamerrors,totalfit,functionintegrals,alphavar]...
%        =slept2resid(sleptcorrected,thedates,[3 365.0],[],{2 'periodic' 1728},CC,TH);
[ESTsignal,ESTresid,ftests,extravalues,total,alphavarall,totalparams, ...
     totalparamerrors,totalfit,functionintegrals,alphavar]...
        =slept2resid(sleptcorrected,thedates,[3 365.0 182.5],[],[],CC(1:round(N)),TH);

    
[ESTsignal,ESTresid,ftests,extravalues,total,alphavarall,totalparams, ...
     totalparamerrors,totalfit,functionintegrals,alphavar,fgls_coeff,fgls_2sigma,fgls_pred,fgls_residvar]...
        =slept2resid_fgls(sleptcorrected,thedates,[3 365.0 182.5],[],[],CC(1:round(N)),TH);
    
    % Because acceleration is twice the coefficient value
    fgls_coeff(2) = fgls_coeff(2)*2;
    fgls_2sigma(2) = fgls_2sigma(2)*2;
    

    
% Find the Shannon number (spharea can take a cell array)
N=round((L+1)^2*spharea(TH));

totalparams(2,:) = totalparams(2,:)*365;
% The acceleration is 2*c2
totalparams(3,:) = 2*totalparams(3,:)*365*365;
totalparamerrors(2,:) = totalparamerrors(2,:)*365;
% Acceleration error is 2*c2error
totalparamerrors(3,:) = 2*totalparamerrors(3,:)*365*365;



%%%
% PLOTTING
%%%

figure
errorbar(thedates,total,ones(1,length(thedates))*sqrt(alphavarall)*1.99,'k-')
ylim([-500 500])
hold on
plot(totalfit(:,1),totalfit(:,3),'b-',totalfit(:,1),totalfit(:,3)+totalfit(:,5),'b--',...
    totalfit(:,1),totalfit(:,3)-totalfit(:,5),'b--')
datetick('x',28)
text(datenum('01-Jan-2003'),-1500,...
    ['Slope = ' num2str(totalparams(2,2)) ' +- ' num2str(totalparamerrors(2,2))...
    ' Gt/yr'])
text(datenum('01-Jan-2003'),-1800,...
    ['Acceleration = ' num2str(totalparams(3,2)) ' +- ' num2str(totalparamerrors(3,2))...
    ' Gt/yr'])
ylabel('Mass (Gt)')
title(['Integrated Mass Change for Greenland, L = ' num2str(L) ...
    ', buffer = ' num2str(XYbuffer) ' deg'])


figure
errorbar(thedates,total,ones(1,length(thedates))*sqrt(fgls_residvar)*1.99,'k-')
ylim([-500 500])
hold on
plot(totalfit(:,1),fgls_pred,'b-')
%   plot(totalfit(:,1),totalfit(:,2),'b-',totalfit(:,1),totalfit(:,2)+totalfit(:,5),'b--',...
%       totalfit(:,1),totalfit(:,2)-totalfit(:,5),'b--')
datetick('x',28)
text(datenum('01-Jan-2003'),-1500,...
    ['Slope = ' num2str(fgls_coeff(1)) ' +- ' num2str(fgls_2sigma(1))...
    ' Gt/yr'])
text(datenum('01-Jan-2003'),-1800,...
    ['Acceleration = ' num2str(fgls_coeff(2)) ' +- ' num2str(fgls_2sigma(2))...
    ' Gt/yr'])
ylabel('Mass (Gt)')
title(['Integrated Mass Change (FGLS), L = ' num2str(L) ...
    ', buffer = ' num2str(XYbuffer) ' deg'])

keyboard

%%%
% OUTPUT
%%%

% Save relevant data for use in something like GMT

% Before, we used to see which functions contributed the most, based on
% their estimated slope.  Now this info is not returned to us, and since
% this was the only instance we used it, we can just remember (or check 
% beforehand) which are the 3 biggest and use those.
usefuncs=[1 3 11];

% We are going to only output the functions which add > 10
% of the mass
% change over our time
% usefuncs=[];
% for i=1:N
%     if abs(0(i)) > abs(slope*.1); usefuncs = [usefuncs i]; end
% end

% To get the function time series we just multiply the coefficients by the
% integral of each eigenfunction (Integrals have units of metric gigatons)
functimeseries = sleptcorrected(:,1:N).*repmat(functionintegrals,size(sleptcorrected,1),1);
% And then remove the mean
functimeseries = functimeseries - repmat(mean(functimeseries,1),size(functimeseries,1),1);

%fp1 = fopen(['figures/figdata/SingleFuncLines' Pcenter dom num2str(XYbuffer) num2str(L) ...
%    datestr(thedates(1),28) datestr(thedates(end),28) '.dat'],'wt');
%fp2 = fopen(['figures/figdata/TotalMassLine' Pcenter dom num2str(XYbuffer) num2str(L) ...
%    datestr(thedates(1),28) datestr(thedates(end),28) '.dat'],'wt');
fp2 = fopen(['figures/figdata/TotalIceMass' dom Pcenter num2str(XYbuffer) num2str(L) ...
    datestr(thedates(1),28) datestr(thedates(end),28) '.dat'],'wt');

for temp1=1:nmonths
    if temp1==1
%        fprintf(fp2,'%.0f %.0f %.0f %.0f %i %.1f \n',totalparams(2,2),totalparamerrors(2,2),totalparams(3,2),totalparamerrors(3,2),L,XYbuffer);
        fprintf(fp2,'%.0f %.0f %.0f %.0f %i %.1f \n',fgls_coeff(1),fgls_2sigma(1),fgls_coeff(2),fgls_2sigma(2),L,XYbuffer);
%        fprintf(fp1,'%s \n',num2str(usefuncs)); % the alphas
    end
    
%    tosave1=[];
%    formatstring1=['%s'];
%    for temp2=usefuncs
%      tosave1 = [tosave1 functimeseries(temp1,temp2) alphavar(temp2)];
%      formatstring1 = [formatstring1 ' %.4e %.4e'];
%    end
%    formatstring1 = [formatstring1 '\n'];
    %tosave1 = [functimeseries(1,temp1) alphavar(temp1)];
%    fprintf(fp1,formatstring1,datestr(thedates(temp1),1),tosave1);
    %fprintf(fp2,'%s %.4e %.4e %.4e %.4e %.4e \n',...
    %    datestr(thedates(temp1),1),total(temp1),alphavarall,...
    %    totalfit(temp1,3),totalfit(temp1,3)+totalfit(temp1,5),...
    %    totalfit(temp1,3)-totalfit(temp1,5));
    fprintf(fp2,'%s %.4e %.4e %.4e \n',...
       datestr(thedates(temp1),1),total(temp1),fgls_residvar,...
       fgls_pred(temp1));
%    fprintf(fp2,'%.5e %s %.4e \n',...
%        thedates(temp1),datestr(thedates(temp1),1),total(temp1));
   
end
%fclose(fp1);
fclose(fp2);


