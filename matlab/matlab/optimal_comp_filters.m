%% Clear Workspace and Close figures
clear; close all; clc;

%% Intialize Laplace variable
s = zpk('s');

freqs = logspace(-1, 3, 1000);

% Noise of the sensors
% Let's define the noise characteristics of the two sensors by choosing $W_1$ and $W_2$:
% - Sensor 1 characterized by $W_1$ has low noise at low frequency (for instance a geophone)
% - Sensor 2 characterized by $W_2$ has low noise at high frequency (for instance an accelerometer)


omegac = 2*pi; G0 = 1e-2; Ginf = 1e-6;
W1 = ((sqrt(G0))/(s/omegac + 1))^2;

omegac = 100*2*pi; G0 = 1e-6; Ginf = 1e-2;
W2 = ((sqrt(Ginf)*s/omegac + sqrt(G0))/(s/omegac + 1))^2/(1 + s/2/pi/4000)^2;

omegac = 100*2*pi; G0 = 1e-5; Ginf = 1e-4;
W1 = (Ginf*s/omegac + G0)/(s/omegac + 1)/(1 + s/2/pi/4000);

omegac = 1*2*pi; G0 = 1e-3; Ginf = 1e-8;
W2 = ((sqrt(Ginf)*s/omegac + sqrt(G0))/(s/omegac + 1))^2/(1 + s/2/pi/4000)^2;

figure;
hold on;
plot(freqs, abs(squeeze(freqresp(W1, freqs, 'Hz'))), '-', 'DisplayName', '$W_1$');
plot(freqs, abs(squeeze(freqresp(W2, freqs, 'Hz'))), '-', 'DisplayName', '$W_2$');
set(gca, 'XScale', 'log'); set(gca, 'YScale', 'log');
xlabel('Frequency [Hz]'); ylabel('Magnitude');
hold off;
xlim([freqs(1), freqs(end)]);
legend('location', 'northeast');

% H-Two Synthesis
% We use the generalized plant architecture shown on figure [[fig:h_infinity_optimal_comp_filters]].

% #+name: fig:h_infinity_optimal_comp_filters
% #+caption: $\mathcal{H}_2$ Synthesis - Generalized plant used for the optimal generation of complementary filters
% [[file:figs/h_infinity_optimal_comp_filters.png]]

% The transfer function from $[n_1, n_2]$ to $\hat{x}$ is:
% \[ \begin{bmatrix} W_1 H_1 \\ W_2 (1 - H_1) \end{bmatrix} \]
% If we define $H_2 = 1 - H_1$, we obtain:
% \[ \begin{bmatrix} W_1 H_1 \\ W_2 H_2 \end{bmatrix} \]

% Thus, if we minimize the $\mathcal{H}_2$ norm of this transfer function, we minimize the RMS value of $\hat{x}$.

% We define the generalized plant $P$ on matlab as shown on figure [[fig:h_infinity_optimal_comp_filters]].

P = [0   W2  1;
     W1 -W2  0];



% And we do the $\mathcal{H}_2$ synthesis using the =h2syn= command.

[H1, ~, gamma] = h2syn(P, 1, 1)



% What is minimized is =norm([W1*H1,W2*H2], 2)=.

% Finally, we define $H_2 = 1 - H_1$.

H2 = 1 - H1;

% Analysis
% The complementary filters obtained are shown on figure [[fig:htwo_comp_filters]]. The PSD of the [[fig:psd_sensors_htwo_synthesis]].
% Finally, the RMS value of $\hat{x}$ is shown on table [[tab:rms_results]].
% The optimal sensor fusion has permitted to reduced the RMS value of the estimation error by a factor 6 compare to when using only one sensor.


figure;
hold on;
plot(freqs, abs(squeeze(freqresp(H1, freqs, 'Hz'))), '-', 'DisplayName', '$H_1$');
plot(freqs, abs(squeeze(freqresp(H2, freqs, 'Hz'))), '-', 'DisplayName', '$H_2$');
set(gca, 'XScale', 'log'); set(gca, 'YScale', 'log');
xlabel('Frequency [Hz]'); ylabel('Magnitude');
hold off;
xlim([freqs(1), freqs(end)]);
legend('location', 'northeast');



% #+NAME: fig:htwo_comp_filters
% #+CAPTION: Obtained complementary filters using the $\mathcal{H}_2$ Synthesis ([[./figs/htwo_comp_filters.png][png]], [[./figs/htwo_comp_filters.pdf][pdf]])
% [[file:figs/htwo_comp_filters.png]]


figure;
hold on;
plot(freqs, abs(squeeze(freqresp(W1, freqs, 'Hz'))).^2, '-',  'DisplayName', '$|W_1|^2$');
plot(freqs, abs(squeeze(freqresp(W2, freqs, 'Hz'))).^2, '-',  'DisplayName', '$|W_2|^2$');
plot(freqs, abs(squeeze(freqresp(W1*H1, freqs, 'Hz'))).^2+abs(squeeze(freqresp(W2*H2, freqs, 'Hz'))).^2, 'k-', 'DisplayName', '$|W_1H_1|^2+|W_2H_2|^2$');
set(gca, 'XScale', 'log'); set(gca, 'YScale', 'log');
xlabel('Frequency [Hz]'); ylabel('Magnitude');
hold off;
xlim([freqs(1), freqs(end)]);
legend('location', 'northeast');
