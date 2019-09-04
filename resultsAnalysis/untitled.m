load('/home/rj/finalProject/data/AMERICA_mi_obs_0-050---1-078_1000-pairs_07-Aug-2019_11:48:41/16510__9412__0-06.mat');
textPosX = 76;
textPosX2 = 0;
textPosY = 17;
plotLength = 50;
figure('Name', 'ICA Input/Output Signals', 'Units', 'Inches', 'Position', ...
    [0 0 13.125 5], 'PaperPositionMode', 'auto');

hold on
plot(1:plotLength, testSource(1, 1:plotLength), ':*', 'Color', [0.8500 0.3250 0.0980]);
plot(1: plotLength, observations(2, 1: plotLength), '--+', 'Color', [0.4660 0.6740 0.1880]); 
plot(1: plotLength, icaEstimate(2, 1: plotLength), '-o', 'Color', [0.3010 0.7450 0.9330]);
legend('Source', 'Observation', 'ICA Estimate', 'Location','NorthEast')
xlabel('packet index')
ylabel('byte value')
hold off

title('ICA Input/Output Signals')



print -depsc2 myplot.eps

% figure('Name', 'ICA input/output signals');
% subplot(4, 1, 1);
% plot(1: plotLength, observations(1, 1: plotLength));
% title('ICA Input Signal 1');
% 
% sourceMse1 = immse(observations(1, :), testSource(1, :));
% sourceMse2 = immse(observations(1, :), testSource(2, :));
% strMse = {strcat('Source 1 M.S.E.:', sprintf(' %3.3f', sourceMse1)), ...
%   strcat('Source 2 M.S.E.:', sprintf(' %3.3f', sourceMse2))};
% text(textPosX, textPosY, strMse)
% 
% sourceMi1 = mutInfo(observations(1, :), testSource(1, :));
% sourceMi2 = mutInfo(observations(1, :), testSource(2, :));
% strMi = {strcat('Source 1 M.I.:', sprintf(' %3.3f', sourceMi1)), ...
%   strcat('Source 2 M.I.:', sprintf(' %3.3f', sourceMi2))};
% text(textPosX2, textPosY, strMi)
% 
% subplot(4, 1, 2);
% plot(1: plotLength, observations(2, 1: plotLength));
% title('ICA Input Signal 2');
% 
% sourceMse1 = immse(observations(2, :), testSource(1, :));
% sourceMse2 = immse(observations(2, :), testSource(2, :));
% strMse = {strcat('Source 1 M.S.E.:', sprintf(' %3.3f', sourceMse1)), ...
%   strcat('Source 2 M.S.E.:', sprintf(' %3.3f', sourceMse2))};
% text(textPosX, textPosY, strMse)
% 
% sourceMi1 = mutInfo(observations(2, :), testSource(1, :));
% sourceMi2 = mutInfo(observations(2, :), testSource(2, :));
% strMi = {strcat('Source 1 M.I.:', sprintf(' %3.3f', sourceMi1)), ...
%   strcat('Source 2 M.I.:', sprintf(' %3.3f', sourceMi2))};
% text(textPosX2, textPosY, strMi)
% 
% 
% subplot(4, 1, 3);
% plot(1: plotLength, icaEstimate(1, 1: plotLength));
% title('ICA Output Signal 1');
% 
% sourceMse1 = immse(icaEstimate(1, :), testSource(1, :));
% sourceMse2 = immse(icaEstimate(1, :), testSource(2, :));
% strMse = {strcat('Source 1 M.S.E.:', sprintf(' %3.3f', sourceMse1)), ...
%   strcat('Source 2 M.S.E.:', sprintf(' %3.3f', sourceMse2))};
% text(textPosX, textPosY, strMse)
% 
% sourceMi1 = mutInfo(icaEstimate(1, :), testSource(1, :));
% sourceMi2 = mutInfo(icaEstimate(1, :), testSource(2, :));
% strMi = {strcat('Source 1 M.I.:', sprintf(' %3.3f', sourceMi1)), ...
%   strcat('Source 2 M.I.:', sprintf(' %3.3f', sourceMi2))};
% text(textPosX2, textPosY, strMi)
% 
% subplot(4, 1, 4);
% plot(1: plotLength, icaEstimate(2, 1: plotLength));
% title('ICA Output Signal 2');
% 
% sourceMse1 = immse(icaEstimate(2, :), testSource(1, :));
% sourceMse2 = immse(icaEstimate(2, :), testSource(2, :));
% strMse = {strcat('Source 1 M.S.E.:', sprintf(' %3.3f', sourceMse1)), ...
%   strcat('Source 2 M.S.E.:', sprintf(' %3.3f', sourceMse2))};
% text(textPosX, textPosY, strMse)
% 
% sourceMi1 = mutInfo(icaEstimate(2, :), testSource(1, :));
% sourceMi2 = mutInfo(icaEstimate(2, :), testSource(2, :));
% strMi = {strcat('Source 1 M.I.:', sprintf('%3.3f ', sourceMi1)), ...
%   strcat('Source 2 M.I.:', sprintf(' %3.3f', sourceMi2))};
% text(textPosX2, textPosY, strMi)



