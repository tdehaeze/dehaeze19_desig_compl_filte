%% Clear Workspace and Close figures
clear; close all; clc;

%% Intialize Laplace variable
s = zpk('s');

freqs = logspace(-3, 0, 1000);

% Specifications
% The specifications for the filters are:
% 1. From $0$ to $0.008\text{ Hz}$,the magnitude of the filter’s transfer function should be less than or equal to $8 \times 10^{-3}$
% 2. From $0.008\text{ Hz}$ to $0.04\text{ Hz}$, it attenuates the input signal proportional to frequency cubed
% 3. Between $0.04\text{ Hz}$ and $0.1\text{ Hz}$, the magnitude of the transfer function should be less than 3
% 4. Above $0.1\text{ Hz}$, the maximum of the magnitude of the complement filter should be as close to zero as possible. In our system, we would like to have the magnitude of the complementary filter to be less than $0.1$. As the filters obtained in cite:hua05_low_ligo have a magnitude of $0.045$, we will set that as our requirement

% The specifications are translated in upper bounds of the complementary filters are shown on figure [[fig:ligo_specifications]].


figure;
hold on;
set(gca,'ColorOrderIndex',1)
plot([0.0001, 0.008], [8e-3, 8e-3], ':', 'DisplayName', 'Spec. on $H_H$');
set(gca,'ColorOrderIndex',1)
plot([0.008 0.04], [8e-3, 1], ':', 'HandleVisibility', 'off');
set(gca,'ColorOrderIndex',1)
plot([0.04 0.1], [3, 3], ':', 'HandleVisibility', 'off');
set(gca,'ColorOrderIndex',2)
plot([0.1, 10], [0.045, 0.045], ':', 'DisplayName', 'Spec. on $H_L$');
set(gca, 'XScale', 'log'); set(gca, 'YScale', 'log');
xlabel('Frequency [Hz]'); ylabel('Magnitude');
hold off;
xlim([freqs(1), freqs(end)]);
ylim([1e-4, 10]);
legend('location', 'northeast');

% FIR Filter
% We here try to implement the FIR complementary filter synthesis as explained in cite:hua05_low_ligo.
% For that, we use the [[http://cvxr.com/cvx/][CVX matlab Toolbox]].

% We setup the CVX toolbox and use the =SeDuMi= solver.

cvx_startup;
cvx_solver sedumi;



% We define the frequency vectors on which we will constrain the norm of the FIR filter.

w1 = 0:4.06e-4:0.008;
w2 = 0.008:4.06e-4:0.04;
w3 = 0.04:8.12e-4:0.1;
w4 = 0.1:8.12e-4:0.83;



% We then define the order of the FIR filter.

n = 512;

A1 = [ones(length(w1),1),  cos(kron(w1'.*(2*pi),[1:n-1]))];
A2 = [ones(length(w2),1),  cos(kron(w2'.*(2*pi),[1:n-1]))];
A3 = [ones(length(w3),1),  cos(kron(w3'.*(2*pi),[1:n-1]))];
A4 = [ones(length(w4),1),  cos(kron(w4'.*(2*pi),[1:n-1]))];

B1 = [zeros(length(w1),1), sin(kron(w1'.*(2*pi),[1:n-1]))];
B2 = [zeros(length(w2),1), sin(kron(w2'.*(2*pi),[1:n-1]))];
B3 = [zeros(length(w3),1), sin(kron(w3'.*(2*pi),[1:n-1]))];
B4 = [zeros(length(w4),1), sin(kron(w4'.*(2*pi),[1:n-1]))];



% We run the convex optimization.

cvx_begin

variable y(n+1,1)

% t
maximize(-y(1))

for i = 1:length(w1)
    norm([0 A1(i,:); 0 B1(i,:)]*y) <= 8e-3;
end

for  i = 1:length(w2)
    norm([0 A2(i,:); 0 B2(i,:)]*y) <= 8e-3*(2*pi*w2(i)/(0.008*2*pi))^3;
end

for i = 1:length(w3)
    norm([0 A3(i,:); 0 B3(i,:)]*y) <= 3;
end

for i = 1:length(w4)
    norm([[1 0]'- [0 A4(i,:); 0 B4(i,:)]*y]) <= y(1);
end

cvx_end

h = y(2:end);



% #+RESULTS:
% #+begin_example
% cvx_begin
% variable y(n+1,1)
% % t
% maximize(-y(1))
% for i = 1:length(w1)
%     norm([0 A1(i,:); 0 B1(i,:)]*y) <= 8e-3;
% end
% for  i = 1:length(w2)
%     norm([0 A2(i,:); 0 B2(i,:)]*y) <= 8e-3*(2*pi*w2(i)/(0.008*2*pi))^3;
% end
% for i = 1:length(w3)
%     norm([0 A3(i,:); 0 B3(i,:)]*y) <= 3;
% end
% for i = 1:length(w4)
%     norm([[1 0]'- [0 A4(i,:); 0 B4(i,:)]*y]) <= y(1);
% end
% cvx_end

% Calling SeDuMi 1.34: 4291 variables, 1586 equality constraints
%    For improved efficiency, SeDuMi is solving the dual problem.
% ------------------------------------------------------------
% SeDuMi 1.34 (beta) by AdvOL, 2005-2008 and Jos F. Sturm, 1998-2003.
% Alg = 2: xz-corrector, Adaptive Step-Differentiation, theta = 0.250, beta = 0.500
% eqs m = 1586, order n = 3220, dim = 4292, blocks = 1073
% nnz(A) = 1100727 + 0, nnz(ADA) = 1364794, nnz(L) = 683190
%  it :     b*y       gap    delta  rate   t/tP*  t/tD*   feas cg cg  prec
%   0 :            4.11E+02 0.000
%   1 :  -2.58E+00 1.25E+02 0.000 0.3049 0.9000 0.9000   4.87  1  1  3.0E+02
%   2 :  -2.36E+00 3.90E+01 0.000 0.3118 0.9000 0.9000   1.83  1  1  6.6E+01
%   3 :  -1.69E+00 1.31E+01 0.000 0.3354 0.9000 0.9000   1.76  1  1  1.5E+01
%   4 :  -8.60E-01 7.10E+00 0.000 0.5424 0.9000 0.9000   2.48  1  1  4.8E+00
%   5 :  -4.91E-01 5.44E+00 0.000 0.7661 0.9000 0.9000   3.12  1  1  2.5E+00
%   6 :  -2.96E-01 3.88E+00 0.000 0.7140 0.9000 0.9000   2.62  1  1  1.4E+00
%   7 :  -1.98E-01 2.82E+00 0.000 0.7271 0.9000 0.9000   2.14  1  1  8.5E-01
%   8 :  -1.39E-01 2.00E+00 0.000 0.7092 0.9000 0.9000   1.78  1  1  5.4E-01
%   9 :  -9.99E-02 1.30E+00 0.000 0.6494 0.9000 0.9000   1.51  1  1  3.3E-01
%  10 :  -7.57E-02 8.03E-01 0.000 0.6175 0.9000 0.9000   1.31  1  1  2.0E-01
%  11 :  -5.99E-02 4.22E-01 0.000 0.5257 0.9000 0.9000   1.17  1  1  1.0E-01
%  12 :  -5.28E-02 2.45E-01 0.000 0.5808 0.9000 0.9000   1.08  1  1  5.9E-02
%  13 :  -4.82E-02 1.28E-01 0.000 0.5218 0.9000 0.9000   1.05  1  1  3.1E-02
%  14 :  -4.56E-02 5.65E-02 0.000 0.4417 0.9045 0.9000   1.02  1  1  1.4E-02
%  15 :  -4.43E-02 2.41E-02 0.000 0.4265 0.9004 0.9000   1.01  1  1  6.0E-03
%  16 :  -4.37E-02 8.90E-03 0.000 0.3690 0.9070 0.9000   1.00  1  1  2.3E-03
%  17 :  -4.35E-02 3.24E-03 0.000 0.3641 0.9164 0.9000   1.00  1  1  9.5E-04
%  18 :  -4.34E-02 1.55E-03 0.000 0.4788 0.9086 0.9000   1.00  1  1  4.7E-04
%  19 :  -4.34E-02 8.77E-04 0.000 0.5653 0.9169 0.9000   1.00  1  1  2.8E-04
%  20 :  -4.34E-02 5.05E-04 0.000 0.5754 0.9034 0.9000   1.00  1  1  1.6E-04
%  21 :  -4.34E-02 2.94E-04 0.000 0.5829 0.9136 0.9000   1.00  1  1  9.9E-05
%  22 :  -4.34E-02 1.63E-04 0.015 0.5548 0.9000 0.0000   1.00  1  1  6.6E-05
%  23 :  -4.33E-02 9.42E-05 0.000 0.5774 0.9053 0.9000   1.00  1  1  3.9E-05
%  24 :  -4.33E-02 6.27E-05 0.000 0.6658 0.9148 0.9000   1.00  1  1  2.6E-05
%  25 :  -4.33E-02 3.75E-05 0.000 0.5972 0.9187 0.9000   1.00  1  1  1.6E-05
%  26 :  -4.33E-02 1.89E-05 0.000 0.5041 0.9117 0.9000   1.00  1  1  8.6E-06
%  27 :  -4.33E-02 9.72E-06 0.000 0.5149 0.9050 0.9000   1.00  1  1  4.5E-06
%  28 :  -4.33E-02 2.94E-06 0.000 0.3021 0.9194 0.9000   1.00  1  1  1.5E-06
%  29 :  -4.33E-02 9.73E-07 0.000 0.3312 0.9189 0.9000   1.00  2  2  5.3E-07
%  30 :  -4.33E-02 2.82E-07 0.000 0.2895 0.9063 0.9000   1.00  2  2  1.6E-07
%  31 :  -4.33E-02 8.05E-08 0.000 0.2859 0.9049 0.9000   1.00  2  2  4.7E-08
%  32 :  -4.33E-02 1.43E-08 0.000 0.1772 0.9059 0.9000   1.00  2  2  8.8E-09

% iter seconds digits       c*x               b*y
%  32     49.4   6.8 -4.3334083581e-02 -4.3334090214e-02
% |Ax-b| =   3.7e-09, [Ay-c]_+ =   1.1E-10, |x|=  1.0e+00, |y|=  2.6e+00

% Detailed timing (sec)
%    Pre          IPM          Post
% 3.902E+00    4.576E+01    1.035E-02
% Max-norms: ||b||=1, ||c|| = 3,
% Cholesky |add|=0, |skip| = 0, ||L.L|| = 4.26267.
% ------------------------------------------------------------
% Status: Solved
% Optimal value (cvx_optval): -0.0433341
% h = y(2:end);
% #+end_example

% Finally, we compute the filter response over the frequency vector defined and the result is shown on figure [[fig:fir_filter_ligo]] which is very close to the filters obtain in cite:hua05_low_ligo.


w = [w1 w2 w3 w4];
H = [exp(-j*kron(w'.*2*pi,[0:n-1]))]*h;

figure;

ax1 = subplot(2,1,1);
hold on;
plot(w, abs(H), 'k-');
plot(w, abs(1-H), 'k--');
hold off;
set(gca, 'XScale', 'log'); set(gca, 'YScale', 'log');
ylabel('Magnitude');
set(gca, 'XTickLabel',[]);
ylim([5e-3, 5]);

ax2 = subplot(2,1,2);
hold on;
plot(w, 180/pi*angle(H), 'k-');
plot(w, 180/pi*angle(1-H), 'k--');
hold off;
xlabel('Frequency [Hz]'); ylabel('Phase [deg]');
set(gca, 'XScale', 'log');
yticks([-540:90:360]);

linkaxes([ax1,ax2],'x');
xlim([1e-3, 1]);
xticks([0.01, 0.1, 1, 10, 100, 1000]);

% Weights
% We design weights that will be used for the $\mathcal{H}_\infty$ synthesis of the complementary filters.
% These weights will determine the order of the obtained filters.
% Here are the requirements on the filters:
% - reasonable order
% - to be as close as possible to the specified upper bounds
% - stable minimum phase

% The bode plot of the weights is shown on figure [[fig:ligo_weights]].


w1 = 2*pi*0.008; x1 = 0.35;
w2 = 2*pi*0.04;  x2 = 0.5;
w3 = 2*pi*0.05;  x3 = 0.5;

% Slope of +3 from w1
wH = 0.008*(s^2/w1^2 + 2*x1/w1*s + 1)*(s/w1 + 1);
% Little bump from w2 to w3
wH = wH*(s^2/w2^2 + 2*x2/w2*s + 1)/(s^2/w3^2 + 2*x3/w3*s + 1);
% No Slope at high frequencies
wH = wH/(s^2/w3^2 + 2*x3/w3*s + 1)/(s/w3 + 1);
% Little bump between w2 and w3
w0 = 2*pi*0.045; xi = 0.1; A = 2; n = 1;
wH = wH*((s^2 + 2*w0*xi*A^(1/n)*s + w0^2)/(s^2 + 2*w0*xi*s + w0^2))^n;

wH = 1/wH;
wH = minreal(ss(wH));

n = 20; Rp = 1; Wp = 2*pi*0.102;
[b,a] = cheby1(n, Rp, Wp, 'high', 's');
wL = 0.04*tf(a, b);

wL = 1/wL;
wL = minreal(ss(wL));

figure;
hold on;
set(gca,'ColorOrderIndex',1);
plot(freqs, abs(squeeze(freqresp(inv(wH), freqs, 'Hz'))), '-', 'DisplayName', '$|w_H|^{-1}$');
set(gca,'ColorOrderIndex',2);
plot(freqs, abs(squeeze(freqresp(inv(wL), freqs, 'Hz'))), '-', 'DisplayName', '$|w_L|^{-1}$');

plot([0.0001, 0.008], [8e-3, 8e-3], 'k--', 'DisplayName', 'Spec.');
plot([0.008 0.04], [8e-3, 1], 'k--', 'HandleVisibility', 'off');
plot([0.04 0.1], [3, 3], 'k--', 'HandleVisibility', 'off');
plot([0.1, 10], [0.045, 0.045], 'k--', 'HandleVisibility', 'off');

set(gca, 'XScale', 'log'); set(gca, 'YScale', 'log');
xlabel('Frequency [Hz]'); ylabel('Magnitude');
hold off;
xlim([freqs(1), freqs(end)]);
ylim([1e-3, 10]);
legend('location', 'southeast');

% H-Infinity Synthesis
% We define the generalized plant as shown on figure [[fig:h_infinity_robst_fusion]].

P = [0   wL;
     wH -wH;
     1   0];



% And we do the $\mathcal{H}_\infty$ synthesis using the =hinfsyn= command.

[Hl, ~, gamma, ~] = hinfsyn(P, 1, 1,'TOLGAM', 0.001, 'METHOD', 'ric', 'DISPLAY', 'on');



% #+RESULTS:
% #+begin_example
% [Hl, ~, gamma, ~] = hinfsyn(P, 1, 1,'TOLGAM', 0.001, 'METHOD', 'ric', 'DISPLAY', 'on');
% Resetting value of Gamma min based on D_11, D_12, D_21 terms

% Test bounds:      0.3276 <  gamma  <=      1.8063

%   gamma    hamx_eig  xinf_eig  hamy_eig   yinf_eig   nrho_xy   p/f
%     1.806   1.4e-02 -1.7e-16   3.6e-03   -4.8e-12    0.0000    p
%     1.067   1.3e-02 -4.2e-14   3.6e-03   -1.9e-12    0.0000    p
%     0.697   1.3e-02 -3.0e-01#  3.6e-03   -3.5e-11    0.0000    f
%     0.882   1.3e-02 -9.5e-01#  3.6e-03   -1.2e-34    0.0000    f
%     0.975   1.3e-02 -2.7e+00#  3.6e-03   -1.6e-12    0.0000    f
%     1.021   1.3e-02 -8.7e+00#  3.6e-03   -4.5e-16    0.0000    f
%     1.044   1.3e-02 -6.5e-14   3.6e-03   -3.0e-15    0.0000    p
%     1.032   1.3e-02 -1.8e+01#  3.6e-03    0.0e+00    0.0000    f
%     1.038   1.3e-02 -3.8e+01#  3.6e-03    0.0e+00    0.0000    f
%     1.041   1.3e-02 -8.3e+01#  3.6e-03   -2.9e-33    0.0000    f
%     1.042   1.3e-02 -1.9e+02#  3.6e-03   -3.4e-11    0.0000    f
%     1.043   1.3e-02 -5.3e+02#  3.6e-03   -7.5e-13    0.0000    f

%  Gamma value achieved:     1.0439
% #+end_example

% The high pass filter is defined as $H_H = 1 - H_L$.

Hh = 1 - Hl;

Hh = minreal(Hh);
Hl = minreal(Hl);



% The size of the filters is shown below.


size(Hh), size(Hl)



% #+RESULTS:
% #+begin_example
% size(Hh), size(Hl)
% State-space model with 1 outputs, 1 inputs, and 27 states.
% State-space model with 1 outputs, 1 inputs, and 27 states.
% #+end_example

% The bode plot of the obtained filters as shown on figure [[fig:hinf_synthesis_ligo_results]].


figure;
hold on;
set(gca,'ColorOrderIndex',1);
plot([0.0001, 0.008], [8e-3, 8e-3], ':', 'DisplayName', 'Spec. on $H_H$');
set(gca,'ColorOrderIndex',1);
plot([0.008 0.04], [8e-3, 1], ':', 'HandleVisibility', 'off');
set(gca,'ColorOrderIndex',1);
plot([0.04 0.1], [3, 3], ':', 'HandleVisibility', 'off');

set(gca,'ColorOrderIndex',2);
plot([0.1, 10], [0.045, 0.045], ':', 'DisplayName', 'Spec. on $H_L$');

set(gca,'ColorOrderIndex',1);
plot(freqs, abs(squeeze(freqresp(Hh, freqs, 'Hz'))), '-', 'DisplayName', '$H_H$');
set(gca,'ColorOrderIndex',2);
plot(freqs, abs(squeeze(freqresp(Hl, freqs, 'Hz'))), '-', 'DisplayName', '$H_L$');

set(gca, 'XScale', 'log'); set(gca, 'YScale', 'log');
xlabel('Frequency [Hz]'); ylabel('Magnitude');
hold off;
xlim([freqs(1), freqs(end)]);
ylim([1e-3, 10]);
legend('location', 'southeast');

% Compare FIR and H-Infinity Filters
% Let's now compare the FIR filters designed in cite:hua05_low_ligo and the one obtained with the $\mathcal{H}_\infty$ synthesis on figure [[fig:comp_fir_ligo_hinf]].


figure;
ax1 = subplot(2,1,1);
hold on;
set(gca,'ColorOrderIndex',1);
plot(freqs, abs(squeeze(freqresp(Hh, freqs, 'Hz'))), '-');
set(gca,'ColorOrderIndex',2);
plot(freqs, abs(squeeze(freqresp(Hl, freqs, 'Hz'))), '-');

set(gca,'ColorOrderIndex',1);
plot(w, abs(H), '--');
set(gca,'ColorOrderIndex',2);
plot(w, abs(1-H), '--');
hold off;
set(gca, 'XScale', 'log'); set(gca, 'YScale', 'log');
ylabel('Magnitude');
set(gca, 'XTickLabel',[]);
ylim([1e-3, 10]);

ax2 = subplot(2,1,2);
hold on;
set(gca,'ColorOrderIndex',1);
plot(freqs, 180/pi*angle(squeeze(freqresp(Hh, freqs, 'Hz'))), '-', 'DisplayName', '$\mathcal{H}_\infty$ filters');
set(gca,'ColorOrderIndex',2);
plot(freqs, 180/pi*angle(squeeze(freqresp(Hl, freqs, 'Hz'))), '-', 'HandleVisibility', 'off');

set(gca,'ColorOrderIndex',1);
plot(w, 180/pi*angle(H), '--', 'DisplayName', 'FIR filters');
set(gca,'ColorOrderIndex',2);
plot(w, 180/pi*angle(1-H), '--', 'HandleVisibility', 'off');
set(gca, 'XScale', 'log');
xlabel('Frequency [Hz]'); ylabel('Phase [deg]');
hold off;
yticks([-540:90:360]);
legend('location', 'northeast');

linkaxes([ax1,ax2],'x');
xlim([freqs(1), freqs(end)]);
xticks([0.001, 0.01, 0.1, 1]);
