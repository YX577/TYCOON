clear all; close all; clc;

addpath('../SynthSig');
addpath('../algorithmTYCOON/');

load('DoubleComp');
N = length(s);

M = ceil(N/2);
F = zeros(M,N); % TF matrix

alpha = zeros(1,N); % Alpha vector

nbtmu = 10;
tMuVect = logspace(1,-10,nbtmu); % on teste differents hyperparam lambda

BigAlpha = zeros(N,nbtmu);
BigF = zeros(M,N,nbtmu);

lambda = 0.99;
gamma = 5e-4;

nbxp = 0;
stop_eps = 5e-4;

DEBUG = 0;
for tmu = tMuVect
    nbxp = nbxp+1;
    Fold = F;
    alphaold = alpha;
    mu = tmu*lambda;
    nu = tmu*(1-lambda);
    alpha = zeros(1,N); % Alpha vector

    if DEBUG
        fprintf('\n\nXP %d\n',nbxp);
    end

    [F,alpha] = tycoon(s,Fs,mu,nu,gamma,F,alpha,stop_eps,DEBUG);

    if DEBUG
        t = linspace(0,N/Fs,N);
        figure(1)
        plot(t,s,'b',t,Fs/2/(M-1)*real(sum(F)),'r');

        figure(2)
        plot(t,alpha) ; set(gca, 'fontsize', 24) ;
        xlabel('Time (sec)') ; ylabel('alpha') ; axis tight ;

        figure(3);
        omega = linspace(0,Fs/2,M);
        imagesc(t,omega,log1p(abs(F))); set(gca, 'fontsize', 18) ;
        xlabel('Time (sec)');ylabel('Frequency (Hz)'); axis([0 N/Fs 0 Fs/2]); axis xy ; colormap(1-gray) ;
    end
    drawnow;

    BigF(:,:,nbxp) = F;
    BigAlpha(:,nbxp) = alpha(:);
end


%% Analysis

t = linspace(0,N/Fs,N);
fmax = 5;
% figure(1)
% plot(t,s,'b',t,Fs/2/(M-1)*real(sum(F)),'r');

figure;
% subplot('Position',[0.085 0.1 0.9 0.32]);
% plot(t,cf1/norm(cf1,2),'b',t,alpha/norm(alpha,2),'r','linewidth',2) ; set(gca, 'fontsize', 24) ; 
% legend('$\phi''''_1$','Estimation','interpreter','latex')
% xlabel('Time (sec)') ; ylabel('Chirp factor') ; axis tight ;

subplot('Position',[0.085 0.20 0.41 0.75]);
omega = linspace(0,Fs/2,M);
imagesc(t,omega,log1p(abs(F))); set(gca, 'fontsize', 18) ;
xlabel('Time (s)');ylabel('Frequency (Hz)'); axis([0 N/Fs 0 fmax]); axis xy ; colormap(1-gray) ;

subplot('Position',[0.575 0.20 0.41 0.75]);
omega = linspace(0,Fs/2,M);
imagesc(t,omega,log1p(abs(F)));
hold on; plot(t,if1,'r',t,if2,'b','linewidth',2) ;
set(gca, 'fontsize', 18) ;
xlabel('Time (s)');ylabel('Frequency (Hz)'); axis([0 N/Fs 0 fmax]); axis xy ; colormap(1-gray) ;

%% Comparison
addpath(genpath('OtherMethods'));

% Synchrosqueezing STFT
[tfr, tfrtic, tfrsq, ~, tfrsqtic] = ConceFT_STFT(s, 0, 0.5, 0.0005, 1, 101, 1, 6, 1, 0, 0, 0) ;

%Synchrosqueezing CWT
opts = struct();
opts.motherwavelet = 'Cinfc' ;
opts.CENTER = 1 ;
opts.FWHM = 0.2 ;
tt = linspace(t(1), t(end), length(t)*3) ;
ss = interp1(t, s, tt, 'spline', 'extrap') ;
[tfrsqC, ~, tfrsqticC] = ConceFT_CWT(tt', ss', 0, 5, 5e-3, 1, opts, 0, 0) ;

% EMD
EMDn = 6 ;
allmode = eemd(s,0,1) ;
allmode = allmode(:, 2:EMDn+1) ;

% smooth the result if really need it.
EMDif = zeros(size(allmode)) ; 
EMDam = zeros(size(allmode)) ;
for ii = 1:EMDn
    xhat = hilbert(allmode(:,ii)) ;
    EMDam(:, ii) = abs(xhat) ;
    tmp = phase(xhat) ; 
    tmpif = (tmp(2:end)-tmp(1:end-1))*Fs/2/pi ;
    EMDif(1:end-1,ii) = tmpif ; 
    EMDif(end,ii) = EMDif(end-1,ii) ;
end


%% Graphics

figure;

subplot('Position',[0.085 0.57 0.41 0.4]);
omega = linspace(0,Fs/2,M);
imagesc(t,omega,log1p(abs(tfr))); set(gca, 'fontsize', 18) ;
xlabel('Time (s)');ylabel('Frequency (Hz)'); axis([0 N/Fs 0 fmax]); axis xy ; colormap(1-gray) ;

subplot('Position',[0.575 0.57 0.41 0.4]);
omega = linspace(0,Fs/2,M);
imagesc(t,omega,log1p(abs(tfrsq))); set(gca, 'fontsize', 18) ;
xlabel('Time (s)');ylabel('Frequency (Hz)'); axis([0 N/Fs 0 fmax]); axis xy ; colormap(1-gray) ;

subplot('Position',[0.085 0.09 0.41 0.4]);
omega = linspace(0,Fs/2,M);
imagesc(t,omega,log1p(abs(tfrsqC)));
set(gca, 'fontsize', 18) ;
xlabel('Time (s)');ylabel('Frequency (Hz)'); axis([0 N/Fs 0 fmax]); axis xy ; colormap(1-gray) ;

subplot('Position',[0.575 0.09 0.41 0.4]);
M = max(EMDam(:)) ;
for kk = 1:EMDn 
    for jj = 1: length(t)
        C = max(0, EMDam(jj,kk)) ;
        plot(t(jj), EMDif(jj,kk),'k.','Color',1-[C C C]./M,'MarkerSize',9); hold on ;
    end
end
set(gca,'FontSize',18,'XLim',[0 t(end)],'YLim',[0 5]); 
xlabel('Time (s)'), ylabel('Frequency (Hz)'); colormap(1-gray) ;