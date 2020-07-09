%% Clear Workspace and Close figures
clear; close all; clc;

%% Intialize Laplace variable
s = zpk('s');

freqs = logspace(-1, 3, 1000);

% Design of Weighting Function

% A formula is proposed to help the design of the weighting functions.

% \begin{equation}
%   W(s) = \left( \frac{
%            \frac{1}{\omega_0} \sqrt{\frac{1 - \left(\frac{G_0}{G_c}\right)^{\frac{2}{n}}}{1 - \left(\frac{G_c}{G_\infty}\right)^{\frac{2}{n}}}} s + \left(\frac{G_0}{G_c}\right)^{\frac{1}{n}}
%          }{
%            \left(\frac{1}{G_\infty}\right)^{\frac{1}{n}} \frac{1}{\omega_0} \sqrt{\frac{1 - \left(\frac{G_0}{G_c}\right)^{\frac{2}{n}}}{1 - \left(\frac{G_c}{G_\infty}\right)^{\frac{2}{n}}}} s + \left(\frac{1}{G_c}\right)^{\frac{1}{n}}
%          }\right)^n
% \end{equation}

% The parameters permits to specify:
% - the low frequency gain: $G_0 = lim_{\omega \to 0} |W(j\omega)|$
% - the high frequency gain: $G_\infty = lim_{\omega \to \infty} |W(j\omega)|$
% - the absolute gain at $\omega_0$: $G_c = |W(j\omega_0)|$
% - the absolute slope between high and low frequency: $n$

% The general shape of a weighting function generated using the formula is shown in figure [[fig:weight_formula]].

% #+name: fig:weight_formula
% #+caption: Amplitude of the proposed formula for the weighting functions
% [[file:figs-tikz/weight_formula.png]]


n = 2; w0 = 2*pi*11; G0 = 1/10; G1 = 1000; Gc = 1/2;
W1 = (((1/w0)*sqrt((1-(G0/Gc)^(2/n))/(1-(Gc/G1)^(2/n)))*s + (G0/Gc)^(1/n))/((1/G1)^(1/n)*(1/w0)*sqrt((1-(G0/Gc)^(2/n))/(1-(Gc/G1)^(2/n)))*s + (1/Gc)^(1/n)))^n;

n = 3; w0 = 2*pi*10; G0 = 1000; G1 = 0.1; Gc = 1/2;
W2 = (((1/w0)*sqrt((1-(G0/Gc)^(2/n))/(1-(Gc/G1)^(2/n)))*s + (G0/Gc)^(1/n))/((1/G1)^(1/n)*(1/w0)*sqrt((1-(G0/Gc)^(2/n))/(1-(Gc/G1)^(2/n)))*s + (1/Gc)^(1/n)))^n;

figure;
hold on;
set(gca,'ColorOrderIndex',1)
plot(freqs, 1./abs(squeeze(freqresp(W1, freqs, 'Hz'))), '--', 'DisplayName', '$|W_1|^{-1}$');
set(gca,'ColorOrderIndex',2)
plot(freqs, 1./abs(squeeze(freqresp(W2, freqs, 'Hz'))), '--', 'DisplayName', '$|W_2|^{-1}$');
set(gca, 'XScale', 'log'); set(gca, 'YScale', 'log');
xlabel('Frequency [Hz]'); ylabel('Magnitude');
hold off;
xlim([freqs(1), freqs(end)]);
ylim([5e-4, 20]);
xticks([0.1, 1, 10, 100, 1000]);
legend('location', 'northeast');

% H-Infinity Synthesis
% We define the generalized plant $P$ on matlab.

P = [W1 -W1;
     0   W2;
     1   0];



% And we do the $\mathcal{H}_\infty$ synthesis using the =hinfsyn= command.

[H2, ~, gamma, ~] = hinfsyn(P, 1, 1,'TOLGAM', 0.001, 'METHOD', 'ric', 'DISPLAY', 'on');



% #+RESULTS:
% #+begin_example
% [H2, ~, gamma, ~] = hinfsyn(P, 1, 1,'TOLGAM', 0.001, 'METHOD', 'ric', 'DISPLAY', 'on');
% Resetting value of Gamma min based on D_11, D_12, D_21 terms

% Test bounds:      0.1000 <  gamma  <=   1050.0000

%   gamma    hamx_eig  xinf_eig  hamy_eig   yinf_eig   nrho_xy   p/f
% 1.050e+03   2.8e+01   2.4e-07   4.1e+00    0.0e+00    0.0000    p
%   525.050   2.8e+01   2.4e-07   4.1e+00    0.0e+00    0.0000    p
%   262.575   2.8e+01   2.4e-07   4.1e+00    0.0e+00    0.0000    p
%   131.337   2.8e+01   2.4e-07   4.1e+00   -1.0e-13    0.0000    p
%    65.719   2.8e+01   2.4e-07   4.1e+00   -9.5e-14    0.0000    p
%    32.909   2.8e+01   2.4e-07   4.1e+00    0.0e+00    0.0000    p
%    16.505   2.8e+01   2.4e-07   4.1e+00   -1.0e-13    0.0000    p
%     8.302   2.8e+01   2.4e-07   4.1e+00   -7.2e-14    0.0000    p
%     4.201   2.8e+01   2.4e-07   4.1e+00   -2.5e-25    0.0000    p
%     2.151   2.7e+01   2.4e-07   4.1e+00   -3.8e-14    0.0000    p
%     1.125   2.6e+01   2.4e-07   4.1e+00   -5.4e-24    0.0000    p
%     0.613   2.3e+01 -3.7e+01#  4.1e+00    0.0e+00    0.0000    f
%     0.869   2.6e+01 -3.7e+02#  4.1e+00    0.0e+00    0.0000    f
%     0.997   2.6e+01 -1.1e+04#  4.1e+00    0.0e+00    0.0000    f
%     1.061   2.6e+01   2.4e-07   4.1e+00    0.0e+00    0.0000    p
%     1.029   2.6e+01   2.4e-07   4.1e+00    0.0e+00    0.0000    p
%     1.013   2.6e+01   2.4e-07   4.1e+00    0.0e+00    0.0000    p
%     1.005   2.6e+01   2.4e-07   4.1e+00    0.0e+00    0.0000    p
%     1.001   2.6e+01 -3.1e+04#  4.1e+00   -3.8e-14    0.0000    f
%     1.003   2.6e+01 -2.8e+05#  4.1e+00    0.0e+00    0.0000    f
%     1.004   2.6e+01   2.4e-07   4.1e+00   -5.8e-24    0.0000    p
%     1.004   2.6e+01   2.4e-07   4.1e+00    0.0e+00    0.0000    p

%  Gamma value achieved:     1.0036
% #+end_example

% We then define the high pass filter $H_1 = 1 - H_2$. The bode plot of both $H_1$ and $H_2$ is shown on figure [[fig:hinf_filters_results]].


H1 = 1 - H2;

% Obtained Complementary Filters
% The obtained complementary filters are shown on figure [[fig:hinf_filters_results]].


figure;

ax1 = subplot(2,1,1);
hold on;
set(gca,'ColorOrderIndex',1)
plot(freqs, 1./abs(squeeze(freqresp(W1, freqs, 'Hz'))), '--', 'DisplayName', '$w_1$');
set(gca,'ColorOrderIndex',2)
plot(freqs, 1./abs(squeeze(freqresp(W2, freqs, 'Hz'))), '--', 'DisplayName', '$w_2$');

set(gca,'ColorOrderIndex',1)
plot(freqs, abs(squeeze(freqresp(H1, freqs, 'Hz'))), '-', 'DisplayName', '$H_1$');
set(gca,'ColorOrderIndex',2)
plot(freqs, abs(squeeze(freqresp(H2, freqs, 'Hz'))), '-', 'DisplayName', '$H_2$');
set(gca, 'XScale', 'log'); set(gca, 'YScale', 'log');
hold off;
set(gca, 'XScale', 'log'); set(gca, 'YScale', 'log');
ylabel('Magnitude');
set(gca, 'XTickLabel',[]);
ylim([5e-4, 20]);
legend('location', 'northeast');

ax2 = subplot(2,1,2);
hold on;
set(gca,'ColorOrderIndex',1)
plot(freqs, 180/pi*phase(squeeze(freqresp(H1, freqs, 'Hz'))), '-');
set(gca,'ColorOrderIndex',2)
plot(freqs, 180/pi*phase(squeeze(freqresp(H2, freqs, 'Hz'))), '-');
hold off;
xlabel('Frequency [Hz]'); ylabel('Phase [deg]');
set(gca, 'XScale', 'log');
yticks([-360:90:360]);

linkaxes([ax1,ax2],'x');
xlim([freqs(1), freqs(end)]);
xticks([0.1, 1, 10, 100, 1000]);
