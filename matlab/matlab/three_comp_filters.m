%% Clear Workspace and Close figures
clear; close all; clc;

%% Intialize Laplace variable
s = zpk('s');

freqs = logspace(-2, 4, 1000);

% Weights
% First we define the weights.

n = 2; w0 = 2*pi*1; G0 = 1/10; G1 = 1000; Gc = 1/2;
W1 = (((1/w0)*sqrt((1-(G0/Gc)^(2/n))/(1-(Gc/G1)^(2/n)))*s + (G0/Gc)^(1/n))/((1/G1)^(1/n)*(1/w0)*sqrt((1-(G0/Gc)^(2/n))/(1-(Gc/G1)^(2/n)))*s + (1/Gc)^(1/n)))^n;

W2 = 0.22*(1 + s/2/pi/1)^2/(sqrt(1e-4) + s/2/pi/1)^2*(1 + s/2/pi/10)^2/(1 + s/2/pi/1000)^2;

n = 3; w0 = 2*pi*10; G0 = 1000; G1 = 0.1; Gc = 1/2;
W3 = (((1/w0)*sqrt((1-(G0/Gc)^(2/n))/(1-(Gc/G1)^(2/n)))*s + (G0/Gc)^(1/n))/((1/G1)^(1/n)*(1/w0)*sqrt((1-(G0/Gc)^(2/n))/(1-(Gc/G1)^(2/n)))*s + (1/Gc)^(1/n)))^n;

figure;
hold on;
set(gca,'ColorOrderIndex',1)
plot(freqs, 1./abs(squeeze(freqresp(W1, freqs, 'Hz'))), '--', 'DisplayName', '$|W_1|^{-1}$');
set(gca,'ColorOrderIndex',2)
plot(freqs, 1./abs(squeeze(freqresp(W2, freqs, 'Hz'))), '--', 'DisplayName', '$|W_2|^{-1}$');
set(gca,'ColorOrderIndex',3)
plot(freqs, 1./abs(squeeze(freqresp(W3, freqs, 'Hz'))), '--', 'DisplayName', '$|W_3|^{-1}$');
set(gca, 'XScale', 'log'); set(gca, 'YScale', 'log');
xlabel('Frequency [Hz]'); ylabel('Magnitude');
hold off;
xlim([freqs(1), freqs(end)]);
xticks([0.01, 0.1, 1, 10, 100, 1000]);
legend('location', 'northeast');

T = table(freqs', ...
          1./abs(squeeze(freqresp(W1, freqs, 'Hz'))), ...
          1./abs(squeeze(freqresp(W2, freqs, 'Hz'))), ...
          1./abs(squeeze(freqresp(W3, freqs, 'Hz'))), ...
          'VariableNames', {'freqs', 'W1', 'W2', 'W3'});
writetable(T, 'mat/hinf_three_weights.csv');

% H-Infinity Synthesis
% Then we create the generalized plant =P=.

P = [W1 -W1 -W1;
     0   W2  0 ;
     0   0   W3;
     1   0   0];



% And we do the $\mathcal{H}_\infty$ synthesis.

[H, ~, gamma, ~] = hinfsyn(P, 1, 2,'TOLGAM', 0.001, 'METHOD', 'ric', 'DISPLAY', 'on');

% Obtained Complementary Filters
% The obtained filters are:

H2 = tf(H(1));
H3 = tf(H(2));
H1 = 1 - H2 - H3;

figure;

ax1 = subplot(2,1,1);
hold on;
set(gca,'ColorOrderIndex',1)
plot(freqs, 1./abs(squeeze(freqresp(W1, freqs, 'Hz'))), '--', 'DisplayName', '$|W_1|^{-1}$');
set(gca,'ColorOrderIndex',2)
plot(freqs, 1./abs(squeeze(freqresp(W2, freqs, 'Hz'))), '--', 'DisplayName', '$|W_2|^{-1}$');
set(gca,'ColorOrderIndex',3)
plot(freqs, 1./abs(squeeze(freqresp(W3, freqs, 'Hz'))), '--', 'DisplayName', '$|W_3|^{-1}$');
set(gca,'ColorOrderIndex',1)
plot(freqs, abs(squeeze(freqresp(H1, freqs, 'Hz'))), '-', 'DisplayName', '$H_1$');
set(gca,'ColorOrderIndex',2)
plot(freqs, abs(squeeze(freqresp(H2, freqs, 'Hz'))), '-', 'DisplayName', '$H_2$');
set(gca,'ColorOrderIndex',3)
plot(freqs, abs(squeeze(freqresp(H3, freqs, 'Hz'))), '-', 'DisplayName', '$H_3$');
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
plot(freqs, 180/pi*phase(squeeze(freqresp(H1, freqs, 'Hz'))));
set(gca,'ColorOrderIndex',2)
plot(freqs, 180/pi*phase(squeeze(freqresp(H2, freqs, 'Hz'))));
set(gca,'ColorOrderIndex',3)
plot(freqs, 180/pi*phase(squeeze(freqresp(H3, freqs, 'Hz'))));
hold off;
xlabel('Frequency [Hz]'); ylabel('Phase [deg]');
set(gca, 'XScale', 'log');
yticks([-360:90:360]);

linkaxes([ax1,ax2],'x');
xlim([freqs(1), freqs(end)]);
xticks([0.1, 1, 10, 100, 1000]);

T = table(freqs', ...
          abs(squeeze(freqresp(H1, freqs, 'Hz'))), ...
          abs(squeeze(freqresp(H2, freqs, 'Hz'))), ...
          abs(squeeze(freqresp(H3, freqs, 'Hz'))), ...
          180/pi*phase(squeeze(freqresp(H1, freqs, 'Hz'))), ...
          180/pi*phase(squeeze(freqresp(H2, freqs, 'Hz'))), ...
          180/pi*phase(squeeze(freqresp(H3, freqs, 'Hz'))), ...
          'VariableNames', {'freqs', 'H1', 'H2', 'H3', 'H1p', 'H2p', 'H3p'});
writetable(T, 'mat/hinf_three_results.csv');
