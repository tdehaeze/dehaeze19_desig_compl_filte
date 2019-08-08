%% Clear Workspace and Close figures
clear; close all; clc;

%% Intialize Laplace variable
s = zpk('s');

freqs = logspace(-1, 3, 1000);

% Weights


omegab = 2*pi*9;
wH = (omegab)^2/(s + omegab*sqrt(1e-5))^2;
omegab = 2*pi*28;
wL = (s + omegab/(4.5)^(1/3))^3/(s*(1e-4)^(1/3) + omegab)^3;

figure;
hold on;
set(gca,'ColorOrderIndex',1)
plot(freqs, 1./abs(squeeze(freqresp(wL, freqs, 'Hz'))), '-', 'DisplayName', '$w_L$');
set(gca,'ColorOrderIndex',2)
plot(freqs, 1./abs(squeeze(freqresp(wH, freqs, 'Hz'))), '-', 'DisplayName', '$w_H$');
set(gca, 'XScale', 'log'); set(gca, 'YScale', 'log');
xlabel('Frequency [Hz]'); ylabel('Magnitude');
hold off;
xlim([freqs(1), freqs(end)]);
ylim([1e-3, 10]);
xticks([0.1, 1, 10, 100, 1000]);
legend('location', 'northeast');

% H-Infinity Synthesis
% We define the generalized plant $P$ on matlab.

P = [0   wL;
     wH -wH;
     1   0];



% And we do the $\mathcal{H}_\infty$ synthesis using the =hinfsyn= command.

[Hl_hinf, ~, gamma, ~] = hinfsyn(P, 1, 1,'TOLGAM', 0.001, 'METHOD', 'ric', 'DISPLAY', 'on');



% #+RESULTS:
% #+begin_example
% [Hl_hinf, ~, gamma, ~] = hinfsyn(P, 1, 1,'TOLGAM', 0.001, 'METHOD', 'ric', 'DISPLAY', 'on');
% Test bounds:      0.0000 <  gamma  <=      1.7285

%   gamma    hamx_eig  xinf_eig  hamy_eig   yinf_eig   nrho_xy   p/f
%     1.729   4.1e+01   8.4e-12   1.8e-01    0.0e+00    0.0000    p
%     0.864   3.9e+01 -5.8e-02#  1.8e-01    0.0e+00    0.0000    f
%     1.296   4.0e+01   8.4e-12   1.8e-01    0.0e+00    0.0000    p
%     1.080   4.0e+01   8.5e-12   1.8e-01    0.0e+00    0.0000    p
%     0.972   3.9e+01 -4.2e-01#  1.8e-01    0.0e+00    0.0000    f
%     1.026   4.0e+01   8.5e-12   1.8e-01    0.0e+00    0.0000    p
%     0.999   3.9e+01   8.5e-12   1.8e-01    0.0e+00    0.0000    p
%     0.986   3.9e+01 -1.2e+00#  1.8e-01    0.0e+00    0.0000    f
%     0.993   3.9e+01 -8.2e+00#  1.8e-01    0.0e+00    0.0000    f
%     0.996   3.9e+01   8.5e-12   1.8e-01    0.0e+00    0.0000    p
%     0.994   3.9e+01   8.5e-12   1.8e-01    0.0e+00    0.0000    p
%     0.993   3.9e+01 -3.2e+01#  1.8e-01    0.0e+00    0.0000    f

%  Gamma value achieved:     0.9942
% #+end_example

% We then define the high pass filter $H_H = 1 - H_L$. The bode plot of both $H_L$ and $H_H$ is shown on figure [[fig:hinf_filters_results]].

Hh_hinf = 1 - Hl_hinf;

% Obtained Complementary Filters

% The obtained complementary filters are shown on figure [[fig:hinf_filters_results]].


figure;
hold on;
set(gca,'ColorOrderIndex',1)
plot(freqs, 1./abs(squeeze(freqresp(wL, freqs, 'Hz'))), '--', 'DisplayName', '$w_L$');
set(gca,'ColorOrderIndex',2)
plot(freqs, 1./abs(squeeze(freqresp(wH, freqs, 'Hz'))), '--', 'DisplayName', '$w_H$');

set(gca,'ColorOrderIndex',1)
plot(freqs, abs(squeeze(freqresp(Hl_hinf, freqs, 'Hz'))), '-', 'DisplayName', '$H_L$ - $\mathcal{H}_\infty$');
set(gca,'ColorOrderIndex',2)
plot(freqs, abs(squeeze(freqresp(Hh_hinf, freqs, 'Hz'))), '-', 'DisplayName', '$H_H$ - $\mathcal{H}_\infty$');
set(gca, 'XScale', 'log'); set(gca, 'YScale', 'log');
xlabel('Frequency [Hz]'); ylabel('Magnitude');
hold off;
xlim([freqs(1), freqs(end)]);
ylim([1e-3, 10]);
xticks([0.1, 1, 10, 100, 1000]);
legend('location', 'northeast');
