%% Clear Workspace and Close figures
clear; close all; clc;

%% Intialize Laplace variable
s = zpk('s');

freqs = logspace(-3, 1, 1000);

% Specifications
% The specifications are:
% 1. From $0$ to $0.008\text{ Hz}$,the magnitude of the filter’s transfer function should be less than or equal to $8 \times 10^{-3}$.
% 2. From $0.008\text{ Hz}$ to $0.04\text{ Hz}$, it attenuates the input signal proportional to frequency cubed
% 3. Between $0.04\text{ Hz}$ and $0.1\text{ Hz}$, the magnitude of the transfer function should be less than 3.
% 4. Above $0.1\text{ Hz}$, the maximum of the magnitude of the complement filter should be as close to zero as possible. In our system ,we would like to have the magnitude of the complementary filter to be less than $0.1$.


figure;
hold on;
set(gca,'ColorOrderIndex',1)
plot([0.0001, 0.008], [8e-3, 8e-3], ':');
set(gca,'ColorOrderIndex',1)
plot([0.008 0.04], [8e-3, 1], ':');
set(gca,'ColorOrderIndex',1)
plot([0.04 0.1], [3, 3], ':');
set(gca,'ColorOrderIndex',2)
plot([0.1, 10], [0.1, 0.1], ':');
set(gca, 'XScale', 'log'); set(gca, 'YScale', 'log');
xlabel('Frequency [Hz]'); ylabel('Magnitude');
hold off;
xlim([freqs(1), freqs(end)]);
ylim([1e-4, 10]);
legend('location', 'northeast');

% Weights

% wH = 130*(((s/2/pi/0.06)+1)^3)/((s/2/pi/0.008)+1)^3;
% wL = 10000*(((s/2/pi/0.6))^3)/((s/2/pi/0.06)+1)^3;
wH = 0.29*(s+0.4262)*(s^2 + 0.2664*s + 0.1455)/((s+0.04299)*(s^2 + 0.04249*s + 0.003472));
wL = 10*s^3/((s+0.6564)*(s^2 + 0.4507*s + 0.3412));
% wL = 361.5*s^3/((s+2.061)*(s^2 + 1.918*s + 4.398));

figure;
hold on;
set(gca,'ColorOrderIndex',1)
plot(freqs, abs(squeeze(freqresp(inv(wH), freqs, 'Hz'))), '-');
set(gca,'ColorOrderIndex',1)
plot([0.0001, 0.008], [8e-3, 8e-3], ':');
set(gca,'ColorOrderIndex',1)
plot([0.008 0.04], [8e-3, 1], ':');
set(gca,'ColorOrderIndex',1)
plot([0.04 0.1], [3, 3], ':');

set(gca,'ColorOrderIndex',2)
plot([0.1, 10], [0.1, 0.1], ':');
set(gca,'ColorOrderIndex',2)
plot(freqs, abs(squeeze(freqresp(inv(wL), freqs, 'Hz'))), '-');

set(gca, 'XScale', 'log'); set(gca, 'YScale', 'log');
xlabel('Frequency [Hz]'); ylabel('Magnitude');
hold off;
xlim([freqs(1), freqs(end)]);
ylim([1e-4, 10]);
legend('location', 'northeast');

% H-Infinity Synthesis

P = [0   wL;
     wH -wH;
     1   0];



% And we do the $\mathcal{H}_\infty$ synthesis using the =hinfsyn= command.

[Hl, ~, gamma, ~] = hinfsyn(P, 1, 1,'TOLGAM', 0.001, 'METHOD', 'ric', 'DISPLAY', 'on');



% #+RESULTS:
% #+begin_example
% [Hl, ~, gamma, ~] = hinfsyn(P, 1, 1,'TOLGAM', 0.001, 'METHOD', 'ric', 'DISPLAY', 'on');
% Resetting value of Gamma min based on D_11, D_12, D_21 terms

% Test bounds:      0.2899 <  gamma  <=      3.6841

%   gamma    hamx_eig  xinf_eig  hamy_eig   yinf_eig   nrho_xy   p/f
%     3.684   6.2e-02   5.3e-05   2.1e-02   -2.8e-36    0.0000    p
%     1.987   5.9e-02   5.4e-05   2.1e-02   -1.1e-12    0.0000    p
%     1.138   5.2e-02 -5.1e-01#  2.1e-02   -3.7e-13    0.0000    f
%     1.563   5.7e-02 -1.8e+00#  2.1e-02    0.0e+00    0.0000    f
%     1.775   5.8e-02 -4.9e+00#  2.1e-02    0.0e+00    0.0000    f
%     1.881   5.9e-02 -1.3e+01#  2.1e-02    0.0e+00    0.0000    f
%     1.934   5.9e-02 -4.3e+01#  2.1e-02    0.0e+00    0.0000    f
%     1.960   5.9e-02   5.4e-05   2.1e-02    0.0e+00    0.0000    p
%     1.947   5.9e-02 -9.9e+01#  2.1e-02   -2.2e-16    0.0000    f
%     1.954   5.9e-02 -2.7e+02#  2.1e-02    0.0e+00    0.0000    f
%     1.957   5.9e-02 -2.0e+03#  2.1e-02   -1.1e-12    0.0000    f
%     1.959   5.9e-02   5.4e-05   2.1e-02    0.0e+00    0.0000    p
%     1.958   5.9e-02   5.4e-05   2.1e-02   -1.1e-12    0.0000    p

%  Gamma value achieved:     1.9580
% #+end_example


Hh = 1 - Hl;

figure;
hold on;
set(gca,'ColorOrderIndex',1)
plot(freqs, abs(squeeze(freqresp(inv(wH), freqs, 'Hz'))), '--');
set(gca,'ColorOrderIndex',1)
plot(freqs, abs(squeeze(freqresp(Hh, freqs, 'Hz'))), '-');
set(gca,'ColorOrderIndex',1)
plot([0.0001, 0.008], [8e-3, 8e-3], ':');
set(gca,'ColorOrderIndex',1)
plot([0.008 0.04], [8e-3, 1], ':');
set(gca,'ColorOrderIndex',1)
plot([0.04 0.1], [3, 3], ':');

set(gca,'ColorOrderIndex',2)
plot([0.1, 10], [0.1, 0.1], ':');
set(gca,'ColorOrderIndex',2)
plot(freqs, abs(squeeze(freqresp(inv(wL), freqs, 'Hz'))), '--');
set(gca,'ColorOrderIndex',2)
plot(freqs, abs(squeeze(freqresp(Hl, freqs, 'Hz'))), '-');

set(gca, 'XScale', 'log'); set(gca, 'YScale', 'log');
xlabel('Frequency [Hz]'); ylabel('Magnitude');
hold off;
xlim([freqs(1), freqs(end)]);
ylim([1e-4, 10]);

% Using Analytical Formula

alpha = 0.5;
beta = 5;
w0 = 2*pi*0.045;

Hh_ana = (s/w0)^3 * ((s/w0)^2 + (1+alpha+beta)*(s/w0) + (1+(alpha+1)*(beta+1)))/((s/w0 + 1)*((s/w0)^2+alpha*(s/w0)+1)*((s/w0)^2+beta*(s/w0)+1));
Hl_ana = ((1+(alpha+1)*(beta+1))*(s/w0)^2 + (1+alpha+beta)*(s/w0) + 1)/((s/w0 + 1)*((s/w0)^2+alpha*(s/w0)+1)*((s/w0)^2+beta*(s/w0)+1));

figure;
hold on;
set(gca,'ColorOrderIndex',1)
plot(freqs, abs(squeeze(freqresp(Hh_ana, freqs, 'Hz'))), '-');
set(gca,'ColorOrderIndex',1)
plot([0.0001, 0.008], [8e-3, 8e-3], ':');
set(gca,'ColorOrderIndex',1)
plot([0.008 0.04], [8e-3, 1], ':');
set(gca,'ColorOrderIndex',1)
plot([0.04 0.1], [3, 3], ':');

set(gca,'ColorOrderIndex',2)
plot([0.1, 10], [0.1, 0.1], ':');
set(gca,'ColorOrderIndex',2)
plot(freqs, abs(squeeze(freqresp(Hl_ana, freqs, 'Hz'))), '-');

set(gca, 'XScale', 'log'); set(gca, 'YScale', 'log');
xlabel('Frequency [Hz]'); ylabel('Magnitude');
hold off;
xlim([freqs(1), freqs(end)]);
ylim([1e-4, 10]);
