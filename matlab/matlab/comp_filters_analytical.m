%% Clear Workspace and Close figures
clear; close all; clc;

%% Intialize Laplace variable
s = zpk('s');

freqs = logspace(-1, 3, 1000);

% Analytical 1st order complementary filters
% First order complementary filters are defined with following equations:
% \begin{align}
%   H_L(s) = \frac{1}{1 + \frac{s}{\omega_0}}\\
%   H_H(s) = \frac{\frac{s}{\omega_0}}{1 + \frac{s}{\omega_0}}
% \end{align}

% Their bode plot is shown figure [[fig:comp_filter_1st_order]].


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

% Second Order Complementary Filters
% We here use analytical formula for the complementary filters $H_L$ and $H_H$.

% The first two formulas that are used to generate complementary filters are:
% \begin{align*}
%   H_L(s) &= \frac{(1+\alpha) (\frac{s}{\omega_0})+1}{\left((\frac{s}{\omega_0})+1\right) \left((\frac{s}{\omega_0})^2 + \alpha (\frac{s}{\omega_0}) + 1\right)}\\
%   H_H(s) &= \frac{(\frac{s}{\omega_0})^2 \left((\frac{s}{\omega_0})+1+\alpha\right)}{\left((\frac{s}{\omega_0})+1\right) \left((\frac{s}{\omega_0})^2 + \alpha (\frac{s}{\omega_0}) + 1\right)}
% \end{align*}
% where:
% - $\omega_0$ is the blending frequency in rad/s.
% - $\alpha$ is used to change the shape of the filters:
%   - Small values for $\alpha$ will produce high magnitude of the filters $|H_L(j\omega)|$ and $|H_H(j\omega)|$ near $\omega_0$ but smaller value for $|H_L(j\omega)|$ above $\approx 1.5 \omega_0$ and for $|H_H(j\omega)|$ below $\approx 0.7 \omega_0$
%   - A large $\alpha$ will do the opposite

% This is illustrated on figure [[fig:comp_filters_param_alpha]].
% The slope of those filters at high and low frequencies is $-2$ and $2$ respectively for $H_L$ and $H_H$.


freqs_study = logspace(-2, 2, 10000);
alphas = [0.1, 1, 10];
w0 = 2*pi*1;

figure;
ax1 = subaxis(2,1,1);
hold on;
for i = 1:length(alphas)
  alpha = alphas(i);
  Hh2 = (s/w0)^2*((s/w0)+1+alpha)/(((s/w0)+1)*((s/w0)^2 + alpha*(s/w0) + 1));
  Hl2 = ((1+alpha)*(s/w0)+1)/(((s/w0)+1)*((s/w0)^2 + alpha*(s/w0) + 1));
  set(gca,'ColorOrderIndex',i);
  plot(freqs_study, abs(squeeze(freqresp(Hh2, freqs_study, 'Hz'))));
  set(gca,'ColorOrderIndex',i);
  plot(freqs_study, abs(squeeze(freqresp(Hl2, freqs_study, 'Hz'))));
end
set(gca, 'XScale', 'log'); set(gca, 'YScale', 'log');
set(gca, 'XTickLabel',[]);
ylabel('Magnitude');
hold off;
ylim([1e-3, 20]);
% Phase
ax2 = subaxis(2,1,2);
hold on;
for i = 1:length(alphas)
  alpha = alphas(i);
  Hh2 = (s/w0)^2*((s/w0)+1+alpha)/(((s/w0)+1)*((s/w0)^2 + alpha*(s/w0) + 1));
  Hl2 = ((1+alpha)*(s/w0)+1)/(((s/w0)+1)*((s/w0)^2 + alpha*(s/w0) + 1));
  set(gca,'ColorOrderIndex',i);
  plot(freqs_study, 180/pi*angle(squeeze(freqresp(Hh2, freqs_study, 'Hz'))), 'DisplayName', sprintf('$\\alpha = %g$', alpha));
  set(gca,'ColorOrderIndex',i);
  plot(freqs_study, 180/pi*angle(squeeze(freqresp(Hl2, freqs_study, 'Hz'))), 'HandleVisibility', 'off');
end
set(gca,'xscale','log');
yticks(-180:90:180);
ylim([-180 180]);
xlabel('Relative Frequency $\frac{\omega}{\omega_0}$'); ylabel('Phase [deg]');
legend('Location', 'northeast');
hold off;
linkaxes([ax1,ax2],'x');
xlim([freqs_study(1), freqs_study(end)]);

% Third Order Complementary Filters
% The following formula gives complementary filters with slopes of $-3$ and $3$:
% \begin{align*}
%   H_L(s) &= \frac{\left(1+(\alpha+1)(\beta+1)\right) (\frac{s}{\omega_0})^2 + (1+\alpha+\beta)(\frac{s}{\omega_0}) + 1}{\left(\frac{s}{\omega_0} + 1\right) \left( (\frac{s}{\omega_0})^2 + \alpha (\frac{s}{\omega_0}) + 1 \right) \left( (\frac{s}{\omega_0})^2 + \beta (\frac{s}{\omega_0}) + 1 \right)}\\
%   H_H(s) &= \frac{(\frac{s}{\omega_0})^3 \left( (\frac{s}{\omega_0})^2 + (1+\alpha+\beta) (\frac{s}{\omega_0}) + (1+(\alpha+1)(\beta+1)) \right)}{\left(\frac{s}{\omega_0} + 1\right) \left( (\frac{s}{\omega_0})^2 + \alpha (\frac{s}{\omega_0}) + 1 \right) \left( (\frac{s}{\omega_0})^2 + \beta (\frac{s}{\omega_0}) + 1 \right)}
% \end{align*}

% The parameters are:
% - $\omega_0$ is the blending frequency in rad/s
% - $\alpha$ and $\beta$ that are used to change the shape of the filters similarly to the parameter $\alpha$ for the second order complementary filters

% The filters are defined below and the result is shown on figure [[fig:complementary_filters_third_order]].


alpha = 1;
beta = 10;
w0 = 2*pi*14;

Hh3_ana = (s/w0)^3 * ((s/w0)^2 + (1+alpha+beta)*(s/w0) + (1+(alpha+1)*(beta+1)))/((s/w0 + 1)*((s/w0)^2+alpha*(s/w0)+1)*((s/w0)^2+beta*(s/w0)+1));
Hl3_ana = ((1+(alpha+1)*(beta+1))*(s/w0)^2 + (1+alpha+beta)*(s/w0) + 1)/((s/w0 + 1)*((s/w0)^2+alpha*(s/w0)+1)*((s/w0)^2+beta*(s/w0)+1));

figure;
hold on;
set(gca,'ColorOrderIndex',1)
plot(freqs, abs(squeeze(freqresp(Hl3_ana, freqs, 'Hz'))), '-', 'DisplayName', '$H_L$ - Analytical');
set(gca,'ColorOrderIndex',2)
plot(freqs, abs(squeeze(freqresp(Hh3_ana, freqs, 'Hz'))), '-', 'DisplayName', '$H_H$ - Analytical');
set(gca, 'XScale', 'log'); set(gca, 'YScale', 'log');
xlabel('Frequency [Hz]'); ylabel('Magnitude');
hold off;
xlim([freqs(1), freqs(end)]);
ylim([1e-3, 10]);
xticks([0.1, 1, 10, 100, 1000]);
legend('location', 'northeast');
