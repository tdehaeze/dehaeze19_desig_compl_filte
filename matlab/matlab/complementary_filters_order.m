%% Clear Workspace and Close figures
clear; close all; clc;

%% Intialize Laplace variable
s = zpk('s');

freqs = logspace(-1, 3, 1000);

% Result
% Their bode plot is shown Fig. ref:fig:comp_filter_1st_order.


w0 = 2*pi; % [rad/s]

Hh1 = (s/w0)/((s/w0)+1);
Hl1 = 1/((s/w0)+1);

freqs = logspace(-2, 2, 1000);

figure;
% Magnitude
ax1 = subaxis(2,1,1);
hold on;
set(gca,'ColorOrderIndex',1); plot(freqs, abs(squeeze(freqresp(Hh1, freqs, 'Hz'))));
set(gca,'ColorOrderIndex',1); plot(freqs, abs(squeeze(freqresp(Hl1, freqs, 'Hz'))));
set(gca, 'XScale', 'log'); set(gca, 'YScale', 'log');
set(gca, 'XTickLabel',[]);
ylabel('Magnitude');
hold off;
% Phase
ax2 = subaxis(2,1,2);
hold on;
set(gca,'ColorOrderIndex',1); plot(freqs, 180/pi*angle(squeeze(freqresp(Hh1, freqs, 'Hz'))));
set(gca,'ColorOrderIndex',1); plot(freqs, 180/pi*angle(squeeze(freqresp(Hl1, freqs, 'Hz'))));
set(gca,'xscale','log');
yticks(-180:90:180);
ylim([-180 180]);
xlabel('Relative Frequency $\frac{\omega}{\omega_0}$'); ylabel('Phase [deg]');
hold off;
linkaxes([ax1,ax2],'x');
xlim([freqs(1), freqs(end)]);



% #+NAME: fig:comp_filter_1st_order
% #+CAPTION: Bode plot of first order complementary filter ([[./figs/comp_filter_1st_order.png][png]], [[./figs/comp_filter_1st_order.pdf][pdf]])
% [[file:figs/comp_filter_1st_order.png]]


% The obtain loop gain $L = H_L{H_H}^{-1}$ is shown Fig. ref:fig:comp_filter_1st_order_loop_gain.


figure;
ax1 = subaxis(2,1,1);
hold on;
plot(freqs, abs(squeeze(freqresp(Hl1/Hh1, freqs, 'Hz'))));
hold off;
set(gca, 'XScale', 'log'); set(gca, 'YScale', 'log');
set(gca, 'XTickLabel',[]);
ylabel('Magnitude');
% Phase
ax2 = subaxis(2,1,2);
hold on;
plot(freqs, 180/pi*angle(squeeze(freqresp(Hl1/Hh1, freqs, 'Hz'))));
hold off;
set(gca,'xscale','log');
yticks(-180:90:180);
ylim([-180 180]);
xlabel('Relative Frequency $\frac{\omega}{\omega_0}$'); ylabel('Phase [deg]');
linkaxes([ax1,ax2],'x');
xlim([freqs(1), freqs(end)]);

% Result
% Bode plots of those filters for multiple values of $\alpha$ are displayed on figure ref:fig:comp_filter_2nd_order_alphas.

% We also plot the loop gain obtained for different values of $\alpha$: $L = H_L{H_H}^{-1}$ (figure ref:fig:comp_filter_2nd_order_loop_gain)


alphas = [0.1, 1, 10, 100];
w0 = 2*pi*1;

figure;
ax1 = subaxis(2,1,1);
hold on;
for i = 1:length(alphas)
  alpha = alphas(i);
  Hh2 = (s/w0)^2*((s/w0)+1+alpha)/(((s/w0)+1)*((s/w0)^2 + alpha*(s/w0) + 1));
  Hl2 = ((1+alpha)*(s/w0)+1)/(((s/w0)+1)*((s/w0)^2 + alpha*(s/w0) + 1));
  set(gca,'ColorOrderIndex',i);
  plot(freqs, abs(squeeze(freqresp(Hh2, freqs, 'Hz'))));
  set(gca,'ColorOrderIndex',i);
  plot(freqs, abs(squeeze(freqresp(Hl2, freqs, 'Hz'))));
end
set(gca, 'XScale', 'log'); set(gca, 'YScale', 'log');
set(gca, 'XTickLabel',[]);
ylabel('Magnitude');
hold off;
ylim([1e-4, 20]);
% Phase
ax2 = subaxis(2,1,2);
hold on;
for i = 1:length(alphas)
  alpha = alphas(i);
  Hh2 = (s/w0)^2*((s/w0)+1+alpha)/(((s/w0)+1)*((s/w0)^2 + alpha*(s/w0) + 1));
  Hl2 = ((1+alpha)*(s/w0)+1)/(((s/w0)+1)*((s/w0)^2 + alpha*(s/w0) + 1));
  set(gca,'ColorOrderIndex',i);
  plot(freqs, 180/pi*angle(squeeze(freqresp(Hh2, freqs, 'Hz'))), 'DisplayName', sprintf('$\\alpha = %g$', alpha));
  set(gca,'ColorOrderIndex',i);
  plot(freqs, 180/pi*angle(squeeze(freqresp(Hl2, freqs, 'Hz'))), 'HandleVisibility', 'off');
end
set(gca,'xscale','log');
yticks(-180:90:180);
ylim([-180 180]);
xlabel('Relative Frequency $\frac{\omega}{\omega_0}$'); ylabel('Phase [deg]');
legend('Location', 'northeast');
hold off;
linkaxes([ax1,ax2],'x');
xlim([freqs(1), freqs(end)]);



% #+NAME: fig:comp_filter_2nd_order_alphas
% #+CAPTION: Second order complementary filters ([[./figs/comp_filter_2nd_order_alphas.png][png]], [[./figs/comp_filter_2nd_order_alphas.pdf][pdf]])
% [[file:figs/comp_filter_2nd_order_alphas.png]]


figure;
ax1 = subaxis(2,1,1);
hold on;
for i = 1:length(alphas)
  alpha = alphas(i);
  Hh2 = (s/w0)^2*((s/w0)+1+alpha)/(((s/w0)+1)*((s/w0)^2 + alpha*(s/w0) + 1));
  Hl2 = ((1+alpha)*(s/w0)+1)/(((s/w0)+1)*((s/w0)^2 + alpha*(s/w0) + 1));
  set(gca,'ColorOrderIndex',i);
  plot(freqs, abs(squeeze(freqresp(Hl2/Hh2, freqs, 'Hz'))));
end
set(gca, 'XScale', 'log'); set(gca, 'YScale', 'log');
set(gca, 'XTickLabel',[]);
hold off;
% Phase
ax2 = subaxis(2,1,2);
hold on;
for i = 1:length(alphas)
  alpha = alphas(i);
  Hh2 = (s/w0)^2*((s/w0)+1+alpha)/(((s/w0)+1)*((s/w0)^2 + alpha*(s/w0) + 1));
  Hl2 = ((1+alpha)*(s/w0)+1)/(((s/w0)+1)*((s/w0)^2 + alpha*(s/w0) + 1));
  set(gca,'ColorOrderIndex',i);
  plot(freqs, 180/pi*angle(squeeze(freqresp(Hl2/Hh2, freqs, 'Hz'))), 'DisplayName', sprintf('$\\alpha = %g$', alpha));
end
hold off;
set(gca,'xscale','log');
yticks(-180:90:180);
ylim([-180 180]);
xlabel('Relative Frequency $\frac{\omega}{\omega_0}$'); ylabel('Phase [deg]');
legend('Location', 'northeast');
linkaxes([ax1,ax2],'x');
xlim([freqs(1), freqs(end)]);

% Parameter Study
% We then study the effect of $\alpha$ on the obtained performance and stability margins (figure ref:fig:comp_filter_2nd_order_study_alphas).


alphas = logspace(-1, 1, 10);

Ms = zeros(1, length(alphas));
dist_reject_w_10 = zeros(1, length(alphas));

for i=1:length(alphas)
  alpha = alphas(i);
  Hh2 = (s/w0)^2*((s/w0)+1+alpha)/(((s/w0)+1)*((s/w0)^2 + alpha*(s/w0) + 1));
  Hl2 = ((1+alpha)*(s/w0)+1)/(((s/w0)+1)*((s/w0)^2 + alpha*(s/w0) + 1));
  Ms(i) = hinfnorm(Hh2);
  dist_reject_w_10(i) = abs(freqresp(Hh2, w0/10));
end

figure;
ax1 = subplot(1, 2, 1);
plot(alphas, 20*log10(Ms./(Ms-1)));
xlabel('$\alpha$'); ylabel('Guaranted GM $\frac{M_S}{M_S-1}$ [dB]');
set(gca, 'XScale', 'log');
ax2 = subplot(1, 2, 2);
plot(alphas, (360/2/pi)./Ms);
xlabel('$\alpha$'); ylabel('Guaranted PM $\frac{1}{M_S}$ [deg]');
set(gca, 'XScale', 'log');



% #+NAME: fig:comp_filter_2nd_order_study_alpha
% #+CAPTION: Guaranted GM and PM as a function of $\alpha$ ([[./figs/comp_filter_2nd_order_study_alpha.png][png]], [[./figs/comp_filter_2nd_order_study_alpha.pdf][pdf]])
% [[file:figs/comp_filter_2nd_order_study_alpha.png]]



figure;
plot(alphas, 20*log10(1./dist_reject_w_10));
xlabel('$\alpha$'); ylabel('Disturbance Rejection at $\frac{\omega_0}{10} [dB]$');
set(gca, 'XScale', 'log');

% Results

alpha = 1;
beta = 10;
w0 = 2*pi*1;

Hh3 = (s/w0)^3 * ((s/w0)^2 + (1+alpha+beta)*(s/w0) + (1+(alpha+1)*(beta+1)))/((s/w0 + 1)*((s/w0)^2+alpha*(s/w0)+1)*((s/w0)^2+beta*(s/w0)+1));
Hl3 = ((1+(alpha+1)*(beta+1))*(s/w0)^2 + (1+alpha+beta)*(s/w0) + 1)/((s/w0 + 1)*((s/w0)^2+alpha*(s/w0)+1)*((s/w0)^2+beta*(s/w0)+1));

alphas = [0.1, 1, 10, 100];
beta = 10;
w0 = 2*pi*1;

figure;
ax1 = subaxis(2,1,1);
hold on;
for i = 1:length(alphas)
  alpha = alphas(i);
  Hh3 = (s/w0)^3 * ((s/w0)^2 + (1+alpha+beta)*(s/w0) + (1+(alpha+1)*(beta+1)))/((s/w0 + 1)*((s/w0)^2+alpha*(s/w0)+1)*((s/w0)^2+beta*(s/w0)+1));
  Hl3 = ((1+(alpha+1)*(beta+1))*(s/w0)^2 + (1+alpha+beta)*(s/w0) + 1)/((s/w0 + 1)*((s/w0)^2+alpha*(s/w0)+1)*((s/w0)^2+beta*(s/w0)+1));
  set(gca,'ColorOrderIndex',i);
  plot(freqs, abs(squeeze(freqresp(Hh3, freqs, 'Hz'))));
  set(gca,'ColorOrderIndex',i);
  plot(freqs, abs(squeeze(freqresp(Hl3, freqs, 'Hz'))));
end
set(gca, 'XScale', 'log'); set(gca, 'YScale', 'log');
set(gca, 'XTickLabel',[]);
ylabel('Magnitude');
ylim([1e-5, 20]);
hold off;
% Phase
ax2 = subaxis(2,1,2);
hold on;
for i = 1:length(alphas)
  alpha = alphas(i);
  Hh3 = (s/w0)^3 * ((s/w0)^2 + (1+alpha+beta)*(s/w0) + (1+(alpha+1)*(beta+1)))/((s/w0 + 1)*((s/w0)^2+alpha*(s/w0)+1)*((s/w0)^2+beta*(s/w0)+1));
  Hl3 = ((1+(alpha+1)*(beta+1))*(s/w0)^2 + (1+alpha+beta)*(s/w0) + 1)/((s/w0 + 1)*((s/w0)^2+alpha*(s/w0)+1)*((s/w0)^2+beta*(s/w0)+1));
  set(gca,'ColorOrderIndex',i);
  plot(freqs, 180/pi*angle(squeeze(freqresp(Hh3, freqs, 'Hz'))), 'DisplayName', sprintf('$\\alpha = %g$', alpha));
  set(gca,'ColorOrderIndex',i);
  plot(freqs, 180/pi*angle(squeeze(freqresp(Hl3, freqs, 'Hz'))), 'HandleVisibility', 'off');
end
set(gca,'xscale','log');
yticks(-180:90:180);
ylim([-180 180]);
xlabel('Relative Frequency $\frac{\omega}{\omega_0}$'); ylabel('Phase [deg]');
legend('Location', 'southeast');
hold off;
linkaxes([ax1,ax2],'x');
xlim([freqs(1), freqs(end)]);



% #+NAME: fig:compt_filter_3rd_order
% #+CAPTION: Bode plot of 3rd order complementary filters, $\beta = 10$ ([[./figs/compt_filter_3rd_order.png][png]], [[./figs/compt_filter_3rd_order.pdf][pdf]])
% [[file:figs/compt_filter_3rd_order.png]]


figure;
ax1 = subaxis(2,1,1);
hold on;
for i = 1:length(alphas)
  alpha = alphas(i);
  Hh3 = (s/w0)^3 * ((s/w0)^2 + (1+alpha+beta)*(s/w0) + (1+(alpha+1)*(beta+1)))/((s/w0 + 1)*((s/w0)^2+alpha*(s/w0)+1)*((s/w0)^2+beta*(s/w0)+1));
  Hl3 = ((1+(alpha+1)*(beta+1))*(s/w0)^2 + (1+alpha+beta)*(s/w0) + 1)/((s/w0 + 1)*((s/w0)^2+alpha*(s/w0)+1)*((s/w0)^2+beta*(s/w0)+1));
  plot(freqs, abs(squeeze(freqresp(Hl3/Hh3, freqs, 'Hz'))));
end
hold off;
set(gca, 'XScale', 'log'); set(gca, 'YScale', 'log');
% Phase
ax2 = subaxis(2,1,2);
hold on;
for i = 1:length(alphas)
  alpha = alphas(i);
  Hh3 = (s/w0)^3 * ((s/w0)^2 + (1+alpha+beta)*(s/w0) + (1+(alpha+1)*(beta+1)))/((s/w0 + 1)*((s/w0)^2+alpha*(s/w0)+1)*((s/w0)^2+beta*(s/w0)+1));
  Hl3 = ((1+(alpha+1)*(beta+1))*(s/w0)^2 + (1+alpha+beta)*(s/w0) + 1)/((s/w0 + 1)*((s/w0)^2+alpha*(s/w0)+1)*((s/w0)^2+beta*(s/w0)+1));
  plot(freqs, 180/pi*angle(squeeze(freqresp(Hl3/Hh3, freqs, 'Hz'))), 'DisplayName', sprintf('$\\alpha = %g$', alpha));
end
hold off;
set(gca,'xscale','log');
yticks(-180:90:180);
ylim([-180 180]);
legend('Location', 'northeast');
xlabel('Relative Frequency $\frac{\omega}{\omega_0}$'); ylabel('Phase [deg]');
linkaxes([ax1,ax2],'x');
xlim([freqs(1), freqs(end)]);

% Parametric Study

alphas = logspace(-1, 1, 10);
Ms = zeros(1, length(alphas));
noise_reject_w_10 = zeros(1, length(alphas));

for i=1:length(alphas)
  alpha = alphas(i);
  beta = 5*alphas(i);
  Hh3 = (s/w0)^3 * ((s/w0)^2 + (1+alpha+beta)*(s/w0) + (1+(alpha+1)*(beta+1)))/((s/w0 + 1)*((s/w0)^2+alpha*(s/w0)+1)*((s/w0)^2+beta*(s/w0)+1));
  Ms(i) = hinfnorm(Hh3);
  noise_reject_w_10(i) = abs(freqresp(Hh3, w0/10));
end

figure;
ax1 = subplot(1, 3, 1);
plot(alphas, 20*log10(Ms./(Ms-1)));
xlabel('$\alpha$'); ylabel('Guaranted Gain Margin $\frac{M_S}{M_S-1}$ [dB]');
set(gca, 'XScale', 'log');
ax2 = subplot(1, 3, 2);
plot(alphas, (360/2/pi)./Ms);
xlabel('$\alpha$'); ylabel('Guaranted Phase Margin $\frac{1}{M_S}$ [deg]');
set(gca, 'XScale', 'log');
ax3 = subplot(1, 3, 3);
plot(alphas, 20*log10(1./noise_reject_w_10));
xlabel('$\alpha$'); ylabel('Disturbance Rejection at $\frac{\omega_0}{10}$ [dB]');
set(gca, 'XScale', 'log');

% Compare 2nd and 3rd order filters
% Compare performance when having similar stability margins.


alpha = 1.7;
beta = 5*1.7;
Hh3 = (s/w0)^3 * ((s/w0)^2 + (1+alpha+beta)*(s/w0) + (1+(alpha+1)*(beta+1)))/((s/w0 + 1)*((s/w0)^2+alpha*(s/w0)+1)*((s/w0)^2+beta*(s/w0)+1));
Hl3 = ((1+(alpha+1)*(beta+1))*(s/w0)^2 + (1+alpha+beta)*(s/w0) + 1)/((s/w0 + 1)*((s/w0)^2+alpha*(s/w0)+1)*((s/w0)^2+beta*(s/w0)+1));

alpha = 1.4;
Hh2 = (s/w0)^2*((s/w0)+1+alpha)/(((s/w0)+1)*((s/w0)^2 + alpha*(s/w0) + 1));
Hl2 = ((1+alpha)*(s/w0)+1)/(((s/w0)+1)*((s/w0)^2 + alpha*(s/w0) + 1));

figure;
ax1 = subaxis(2,1,1);
hold on;
set(gca,'ColorOrderIndex',1);
plot(freqs, abs(squeeze(freqresp(Hh2, freqs, 'Hz'))));
set(gca,'ColorOrderIndex',1);
plot(freqs, abs(squeeze(freqresp(Hl2, freqs, 'Hz'))));
set(gca,'ColorOrderIndex',2);
plot(freqs, abs(squeeze(freqresp(Hh3, freqs, 'Hz'))));
set(gca,'ColorOrderIndex',2);
plot(freqs, abs(squeeze(freqresp(Hl3, freqs, 'Hz'))));
set(gca, 'XScale', 'log'); set(gca, 'YScale', 'log');
set(gca, 'XTickLabel',[]);
ylabel('Magnitude');
ylim([1e-5, 20]);
hold off;
% Phase
ax2 = subaxis(2,1,2);
hold on;
set(gca,'ColorOrderIndex',1);
plot(freqs, 180/pi*angle(squeeze(freqresp(Hh2, freqs, 'Hz'))), 'DisplayName', '2nd order');
set(gca,'ColorOrderIndex',1);
plot(freqs, 180/pi*angle(squeeze(freqresp(Hl2, freqs, 'Hz'))), 'HandleVisibility', 'off');
set(gca,'ColorOrderIndex',2);
plot(freqs, 180/pi*angle(squeeze(freqresp(Hh3, freqs, 'Hz'))), 'DisplayName', '3rd order');
set(gca,'ColorOrderIndex',2);
plot(freqs, 180/pi*angle(squeeze(freqresp(Hl3, freqs, 'Hz'))), 'HandleVisibility', 'off');
set(gca,'xscale','log');
yticks(-180:90:180);
ylim([-180 180]);
xlabel('Relative Frequency $\frac{\omega}{\omega_0}$'); ylabel('Phase [deg]');
legend('Location', 'southeast');
hold off;
linkaxes([ax1,ax2],'x');
xlim([freqs(1), freqs(end)]);



% #+NAME: fig:filter_order_bode_plot
% #+CAPTION: Bode Plot ([[./figs/filter_order_bode_plot.png][png]], [[./figs/filter_order_bode_plot.pdf][pdf]])
% [[file:figs/filter_order_bode_plot.png]]


figure;
ax1 = subaxis(2,1,1);
hold on;
plot(freqs, abs(squeeze(freqresp(Hl2/Hh2, freqs, 'Hz'))));
plot(freqs, abs(squeeze(freqresp(Hl3/Hh3, freqs, 'Hz'))));
set(gca, 'XScale', 'log'); set(gca, 'YScale', 'log');
set(gca, 'XTickLabel',[]);
ylabel('Magnitude');
hold off;
% Phase
ax2 = subaxis(2,1,2);
hold on;
plot(freqs, 180/pi*angle(squeeze(freqresp(Hl2/Hh2, freqs, 'Hz'))), 'DisplayName', '2nd order');
plot(freqs, 180/pi*angle(squeeze(freqresp(Hl3/Hh3, freqs, 'Hz'))), 'DisplayName', '3rd order');
set(gca,'xscale','log');
yticks(-180:90:180);
ylim([-180 180]);
xlabel('Relative Frequency $\frac{\omega}{\omega_0}$'); ylabel('Phase [deg]');
legend('Location', 'southeast');
hold off;
linkaxes([ax1,ax2],'x');
xlim([freqs(1), freqs(end)]);
