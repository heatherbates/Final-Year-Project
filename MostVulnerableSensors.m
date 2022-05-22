clear all;
close all;

load('H_IEEE30.mat')                % Loads IEEE test bus system matrix 'Hx' into workspace

%% Parameter Definitions
H = Hx;                             % Define H as a m x n matrix 
[m,n] = size(H);                    % Define m = number of observations (rows) and n = number of state variable (columns)
x = rand(n,1);                      % Realisations of state variables
sigma=0.01;                         % Std dev of noise 
num_xvals = 500;
variance = linspace(1, 25, num_xvals);      
tau = 1.9;

num_sim = 100000;
prob = zeros(m,num_xvals);              % Create matrix to store probabilities
ph = pinv(H);
num_sensors = 30;

%% Simulate attacks - Targeting individual sensors
tic
for i = 1:num_sensors
    for j = 1:num_xvals
        for k = 1:num_sim
            z = sigma*rand(m,1);                        % Generate random noise
            y = H*x+z;                                  % Linearised system model
            d = zeros(m,1);                             % Create empty attack vector
            d(i) = variance(j)*randn(1);                % Target jth sensor
            y_attack = y + d;                           % Inject attack
            xhat_attack = ph*y_attack;                  % Calculate estimate with attack
            normres(k) = norm(y_attack-H*xhat_attack);  % Calculate the norm of the residual
        end
        % Calculate probability of detection
        prob(i,j) = length(find(normres>tau))/num_sim;    
    end
end
toc
%% Figures
figure(1)   % Line Graph
newDefaultColors = jet(num_sensors);
set(gca, 'ColorOrder', newDefaultColors, 'NextPlot', 'replacechildren');

hold on
for p = 1:num_sensors
    sensor = ['Sensor ' num2str(p)];
    plot(variance, prob(p,:),'DisplayName',sensor)
end
hold off
xlabel('Variance')
ylabel('Probability')
title('Detection Probabilities of Individual Sensors')
legend('Location','eastoutside')

figure(2)   % Heatmap
prob_subset = prob(1:num_sensors,40:100);
averages = mean(prob_subset,2);                     % Calculate avergae of each row
averages_subset = [averages prob_subset];           % Add averages column to matrix
[prob_sorted,index] = sortrows(averages_subset);    % Sort matrix based on average values
prob_sorted = prob_sorted(:,2:end);                 % Remove averages column
xvals = num2cell(variance(40:100));
yvals = num2cell(transpose(index));
h = heatmap(xvals,flip(yvals),flip(prob_sorted));
h.Title = 'Heatmap Identifying Most Vulnerable Sensors';
h.XLabel = 'Variance';
h.YLabel = 'Sensors arranged in order of average probability of detection';
h.Colormap = flip(parula);