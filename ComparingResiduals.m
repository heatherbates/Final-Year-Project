clear all
close all

% Define size of H
m = 400;                            % Rows
n = 30;                             % Columns

y1 = zeros(1,100);
y2 = zeros(1,100);
y3 = zeros(1,100);

for i = 1:100
    H = rand(m,n);                  % Generate random matrix
    x = rand(n,1);
    z = rand(m,1);                  % Generate random noise
    y = H*x+z;

    % No attack
    xhat = pinv(H)*y;               % Calculate estimate
    normres = norm(y-H*xhat);
    y1(i) = normres;

    % Attack vector a=Hc - Good Attack
    c = rand(n,1);
    a = H*c;
    ya = y + a;                     % Add the attack vector
    xhata = pinv(H)*ya;             % Calculate estimate with attack
    normresa = norm(ya-H*xhata);    % Calculate the norm of the residual
    y2(i) = normresa;
    
    % Attack vector b - Bad Attack
    b = rand(m,1);
    yb = y + b;                     % Add the attack vector
    xhatb = pinv(H)*yb;             % Calculate estimate with attack
    normresb = norm(yb-H*xhatb);    % Calculate the norm of the residual
    y3(i) = normresb;
end

% Plot results
figure
x1 = linspace(1,100,100);
scatter(x1,y1,'x')
hold on
scatter(x1,y2)
scatter(x1,y3)
hold off
lgd = legend({'No Attack','Injecting a=Hc','Injecting b'},'Location','southoutside');
lgd.NumColumns = 3;
xlabel('Simulation number')
ylabel('Residual')
title('Comparing residuals of three scenarios')