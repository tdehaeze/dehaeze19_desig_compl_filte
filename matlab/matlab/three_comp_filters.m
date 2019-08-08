%% Clear Workspace and Close figures
clear; close all; clc;

%% Intialize Laplace variable
s = zpk('s');

freqs = logspace(-2, 4, 1000);

% Weights
% First we define the weights.

w1 = 0.35*(1 + s/2/pi/1)^2/(1 + s/2/pi/100)^2;
w2 = 0.35*(1 + s/2/pi/1)^2/(sqrt(1e-4) + s/2/pi/1)^2*(1 + s/2/pi/100)^2/(1 + s/2/pi/10000)^2;
w3 = 0.35*(1 + s/2/pi/100)^2/(sqrt(1e-4) + s/2/pi/100)^2;

figure;
hold on;
set(gca,'ColorOrderIndex',1)
plot(freqs, 1./abs(squeeze(freqresp(w1, freqs, 'Hz'))), '--', 'DisplayName', '$w_1$');
set(gca,'ColorOrderIndex',2)
plot(freqs, 1./abs(squeeze(freqresp(w2, freqs, 'Hz'))), '--', 'DisplayName', '$w_2$');
set(gca,'ColorOrderIndex',3)
plot(freqs, 1./abs(squeeze(freqresp(w3, freqs, 'Hz'))), '--', 'DisplayName', '$w_3$');
set(gca, 'XScale', 'log'); set(gca, 'YScale', 'log');
xlabel('Frequency [Hz]'); ylabel('Magnitude');
hold off;
xlim([freqs(1), freqs(end)]);
xticks([0.01, 0.1, 1, 10, 100, 1000]);
legend('location', 'northeast');

% H-Infinity Synthesis
% Then we create the generalized plant =P=.

P = [w3 -w3 -w3;
     0   w2  0 ;
     0   0   w1;
     1   0   0];



% And we do the $\mathcal{H}_\infty$ synthesis.

[H, ~, gamma, ~] = hinfsyn(P, 1, 2,'TOLGAM', 0.001, 'METHOD', 'ric', 'DISPLAY', 'on');

% Obtained Complementary Filters
% The obtained filters are:

H1 = tf(H(2));
H2 = tf(H(1));
H3 = 1 - H1 - H2;

figure;
hold on;
set(gca,'ColorOrderIndex',1)
plot(freqs, 1./abs(squeeze(freqresp(w1, freqs, 'Hz'))), '--', 'DisplayName', '$w_1$');
set(gca,'ColorOrderIndex',2)
plot(freqs, 1./abs(squeeze(freqresp(w2, freqs, 'Hz'))), '--', 'DisplayName', '$w_2$');
set(gca,'ColorOrderIndex',3)
plot(freqs, 1./abs(squeeze(freqresp(w3, freqs, 'Hz'))), '--', 'DisplayName', '$w_3$');
set(gca,'ColorOrderIndex',1)
plot(freqs, abs(squeeze(freqresp(H1, freqs, 'Hz'))), '-', 'DisplayName', '$H_1$');
set(gca,'ColorOrderIndex',2)
plot(freqs, abs(squeeze(freqresp(H2, freqs, 'Hz'))), '-', 'DisplayName', '$H_2$');
set(gca,'ColorOrderIndex',3)
plot(freqs, abs(squeeze(freqresp(H3, freqs, 'Hz'))), '-', 'DisplayName', '$H_3$');
set(gca, 'XScale', 'log'); set(gca, 'YScale', 'log');
xlabel('Frequency [Hz]'); ylabel('Magnitude');
hold off;
xlim([freqs(1), freqs(end)]);
xticks([0.01, 0.1, 1, 10, 100, 1000]);
legend('location', 'northeast');
