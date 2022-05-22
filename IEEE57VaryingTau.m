clear all;
close all;

load('H_IEEE57.mat')                % Loads IEEE test bus system matrix 'Hx' into workspace

%% Parameter Definitions
H = Hx;                             % Define H as a m x n matrix 
[m,n] = size(H);                    % Define m = number of observations (rows) and n = number of state variable (columns)
ph = pinv(H);                       % Calculate inverse of H

sigma=0.4;                          % Std dev of noise 
num_taus=50;                        % Number of taus for tau-prob curves
taus=linspace(3,4,num_taus);        % Tau parameter for residual detection threshold
std_dev_b=0.1;                      % Std dev of sloppy attack

num_sim=10000;                       % Number of realizations for each simulations point
num_bins=100;                       % Number of bins for histogram plotting

x = rand(n,1);                      % Realisations of state variables

%% Simulate attacks

for tau_index=1:length(taus)            % Loop through threshold values (taus)
    
    tau=taus(tau_index);
    
    for i = 1:num_sim                   % Loop through simulations
        
        z = sigma*rand(m,1);            % Generate random noise
        y = H*x+z;                      % Linearised system model
        
        % No attack
        xhat = ph*y;                    % Calculate estimate
        normres(i) = norm(y-H*xhat);    % Calculate norm of the residual
        
        % Attack vector a=Hc - Good Attack
        c=zeros(n,1);                            % Create empty array for injection atack values
        c(27)=-10;                               % Target specific sensors with any value
        a = H*c;                                 % Multiply by H matrix to form attack vector
        y_a = y + a;                             % Inject the attack vector into the system model
        xhat_a = ph*y_a;                         % Calculate estimate with attack
        normres_a(i) = norm(y_a-H*xhat_a);       % Calculate the norm of the residual
        
        % Attack vector b - Bad Attack
        b = std_dev_b*randn(m,1);                % Generate Gaussian vector with zero mean and variance std_dev_sloppy^2
        y_b = y + b;                             % Inject the sloppy attack vector into the system model
        xhat_b = ph*y_b;                         % Calculate estimate with attack
        normres_b(i) = norm(y_b-H*xhat_b);       % Calculate the norm of the residual
        
    end
    
    % Calculate probablilities
    prob_fa_normal(tau_index)=length(find(normres>=tau))/num_sim;       % Probability of false alarm
    prob_nodet_a(tau_index)=1-length(find(normres_a>=tau))/num_sim;     % Probability of not detecting DIA a
    prob_nodet_b(tau_index)=1-length(find(normres_b>=tau))/num_sim;     % Probability of not detecting DIA b

end

%% Figures

% Histograms (distributions)
%figure(1)
subplot(2,1,1);
histfit(normres,num_bins)
hold on
histfit(normres_b, num_bins)
xlabel('Residual')
ylabel('Number of simulations')
hold off
legend({'No Attack','Lines of best fit','Attack vector b'})
title("Distribution of residuals")

% Probability vs tau curves
%figure(2)
subplot(2,1,2); 
plot(taus, prob_fa_normal)
hold on
plot(taus, prob_nodet_a)
plot(taus, prob_nodet_b)
hold off
legend({'False alarm', 'DIA a=Hc is undetected', 'DIA b is undetected'},'Location','southeast')
xlabel('Threshold (tau)')
ylabel('Probability')
