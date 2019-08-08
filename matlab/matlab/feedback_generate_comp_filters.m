%% Clear Workspace and Close figures
clear; close all; clc;

%% Intialize Laplace variable
s = zpk('s');

freqs = logspace(-2, 2, 1000);

% Loop Gain Design
% Let's first define the loop gain $L$.

wc = 2*pi*1;
alpha = 2;

L = (wc/s)^2 * (s/(wc/alpha) + 1)/(s/wc + alpha);

figure;

ax1 = subplot(2,1,1);
plot(freqs, abs(squeeze(freqresp(L, freqs, 'Hz'))), '-');
ylabel('Magnitude');
set(gca, 'XScale', 'log');
set(gca, 'YScale', 'log');

ax2 = subplot(2,1,2);
plot(freqs, 180/pi*phase(squeeze(freqresp(L, freqs, 'Hz'))), '--');
xlabel('Frequency [Hz]'); ylabel('Phase [deg]');
set(gca, 'XScale', 'log');
ylim([-180, 0]);
yticks([-360:90:360]);

linkaxes([ax1,ax2],'x');
xlim([freqs(1), freqs(end)]);
xticks([0.1, 1, 10, 100, 1000]);

% Complementary Filters Obtained
% We then compute the resulting low pass and high pass filters.

Hl = L/(L + 1);
Hh = 1/(L + 1);

alphas = [1, 2, 10];

figure;
hold on;
for i = 1:length(alphas)
  alpha = alphas(i);
  L = (wc/s)^2 * (s/(wc/alpha) + 1)/(s/wc + alpha);
  Hl = L/(L + 1);
  Hh = 1/(L + 1);
  set(gca,'ColorOrderIndex',i)
  plot(freqs, abs(squeeze(freqresp(Hl, freqs, 'Hz'))), 'DisplayName', sprintf('$\\alpha = %.0f$', alpha));
  set(gca,'ColorOrderIndex',i)
  plot(freqs, abs(squeeze(freqresp(Hh, freqs, 'Hz'))), 'HandleVisibility', 'off');
end
set(gca, 'xscale', 'log'); set(gca, 'yscale', 'log');
xlabel('Frequency [Hz]'); ylabel('Amplitude')
legend('location', 'northeast');
