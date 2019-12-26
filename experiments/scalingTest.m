% search for the optimal scaling coefficients and evaluate the results 
% as compared to scaling optimization using MSE minimization
clear all;
workspaceName = 'data/AMERICA_mi_obs_0-050---1-078_1000-pairs_07-Aug-2019_11:48:41/16510__9412__0-06.mat';

% load the separation data
load(workspaceName);

% rename variables whose original handles are ambiguous 
source = testSource;
base = 2;
degree = 4;
field = gftuple((-1:base^degree-2)', degree, base); % Construct list of elements.
numSources = size(source,1);
packetLength = size(source, 2);

icaAlgo =  'AMERICA';
load('data/ipAddresses');

% port number overlap
portNumbers = [...
            % ethernet II
            % Type: IPv4 (0x0800)
            0 8 0 0;...
            % udp port numbers
            1 15 9 0;...
            9 11 6 1;...
            % tcp port numbers
            0 12 7 9;...
            0 0 5 0;...
            0 12 8 0;];

information = zeros(size(ipAddresses,1), size(ipAddresses,2), 2);
% for majority voting, store the ip addreses
information(:,:,1) = ipAddresses;
% for majority voting, store the port numbers
information(1:size(portNumbers,1), 1:size(portNumbers,2), 2) = portNumbers;

infoUnits = zeros(2);
infoUnits(1,:) = size(ipAddresses);
infoUnits(2,:) = size(portNumbers);

%% print results and analysis plots for source separation

% compute the MSE between the two source packets
sourceMse = immse(source(1, :), source(2, :));
% compute the MI between the two source packets
sourceMi = mutInfo(source(1, :), source(2, :));

plotLength = 100;
textPosX = 80;
textPosY = 16;
textPosX2 = 0;

% figure which holds the original source signals
figure('Name', 'Original signals');
subplot(numSources, 1, 1);
plot(1: plotLength, source(1, 1: plotLength));
title('source signal 1');
strMse = {strcat('mse = ', sprintf(' %3.3f', sourceMse))};
strMi = {strcat('mi = ', sprintf(' %3.3f', sourceMi))};
text(textPosX, textPosY, strMse)
text(textPosX2, textPosY, strMi)

subplot(numSources, 1, 2);
plot(1: plotLength, source(2, 1: plotLength));
title('source signal 2');


%% plot the ICA i/o signals
textPosY = 17;
figure('Name', 'ICA input/output signals');
subplot(4, 1, 1);
plot(1: plotLength, observations(1, 1: plotLength));
title('ICA input signal 1');

sourceMse1 = immse(observations(1, :), source(1, :));
sourceMse2 = immse(observations(1, :), source(2, :));
strMse = {strcat('src 1 mse:', sprintf(' %3.3f', sourceMse1)), ...
  strcat('src 2 mse:', sprintf(' %3.3f', sourceMse2))};
text(textPosX, textPosY, strMse)

sourceMi1 = mutInfo(observations(1, :), source(1, :));
sourceMi2 = mutInfo(observations(1, :), source(2, :));
strMi = {strcat('src 1 mi:', sprintf(' %3.3f', sourceMi1)), ...
  strcat('src 2 mi:', sprintf(' %3.3f', sourceMi2))};
text(textPosX2, textPosY, strMi)

subplot(4, 1, 2);
plot(1: plotLength, observations(2, 1: plotLength));
title('ICA input signal 2');

sourceMse1 = immse(observations(2, :), source(1, :));
sourceMse2 = immse(observations(2, :), source(2, :));
strMse = {strcat('src 1 mse:', sprintf(' %3.3f', sourceMse1)), ...
  strcat('src 2 mse:', sprintf(' %3.3f', sourceMse2))};
text(textPosX, textPosY, strMse)

sourceMi1 = mutInfo(observations(2, :), source(1, :));
sourceMi2 = mutInfo(observations(2, :), source(2, :));
strMi = {strcat('src 1 mi:', sprintf(' %3.3f', sourceMi1)), ...
  strcat('src 2 mi:', sprintf(' %3.3f', sourceMi2))};
text(textPosX2, textPosY, strMi)


subplot(4, 1, 3);
plot(1: plotLength, icaEstimate(1, 1: plotLength));
title('ICA output signal 1');

sourceMse1 = immse(icaEstimate(1, :), source(1, :));
sourceMse2 = immse(icaEstimate(1, :), source(2, :));
strMse = {strcat('src 1 mse:', sprintf(' %3.3f', sourceMse1)), ...
  strcat('src 2 mse:', sprintf(' %3.3f', sourceMse2))};
text(textPosX, textPosY, strMse)

sourceMi1 = mutInfo(icaEstimate(1, :), source(1, :));
sourceMi2 = mutInfo(icaEstimate(1, :), source(2, :));
strMi = {strcat('src 1 mi:', sprintf(' %3.3f', sourceMi1)), ...
  strcat('src 2 mi:', sprintf(' %3.3f', sourceMi2))};
text(textPosX2, textPosY, strMi)

subplot(4, 1, 4);
plot(1: plotLength, icaEstimate(2, 1: plotLength));
title('ICA output signal 2');

sourceMse1 = immse(icaEstimate(2, :), source(1, :));
sourceMse2 = immse(icaEstimate(2, :), source(2, :));
strMse = {strcat('src 1 mse:', sprintf(' %3.3f', sourceMse1)), ...
  strcat('src 2 mse:', sprintf(' %3.3f', sourceMse2))};
text(textPosX, textPosY, strMse)

sourceMi1 = mutInfo(icaEstimate(2, :), source(1, :));
sourceMi2 = mutInfo(icaEstimate(2, :), source(2, :));
strMi = {strcat('src 1 mi:', sprintf('%3.3f ', sourceMi1)), ...
  strcat('src 2 mi:', sprintf(' %3.3f', sourceMi2))};
text(textPosX2, textPosY, strMi)

 %% Find the optimal scaling coefficients by maximizing the overlap of signal
 %% segments containing neighboring repetitions.
 
[scalingFactor, scaledSourceEstimate]  = ...
 scalingFactorByMajorityVoting(...
 	information, infoUnits, icaEstimate, base, degree, field, icaAlgo);

% 
% % find repeating elements for source signals
% [sourceRepeats1(1, :), sourceRepeats1(2, :), sourceRepeats1(3, :)] = ....
%   findRepeats(source(1, :));
% 
% [sourceRepeats2(1, :), sourceRepeats2(2, :), sourceRepeats2(3, :)] = ....
%   findRepeats(source(2, :));
% 
% 
% %% Plot comparison of scaled estimated signal and original source signals
% figureNumber = 1;
% numComparedSignals = 1;
% textPosY = 15;
% 
% figure('Name', 'signal optimization using scaling factors');
% for src_it = 1 : numSources
% 
%     subplot(numComparedSignals * numSources, 1, figureNumber);
%     plot(1: plotLength, scaledSourceEstimate(src_it, 1:plotLength)); 
%     title(strcat('max overlap score -- scaled estimate signal ', string(src_it)));
%     
%     % compute the mse between the estimate and each of the source packets
%     sourceMse1 = immse(scaledSourceEstimate(src_it, :), source(1, :));
%     sourceMse2 = immse(scaledSourceEstimate(src_it, :), source(2, :));
%     strMse = {strcat('mse w/ s1:', sprintf(' %3.3f', sourceMse1)), ...
%      strcat('mse w/ s2:', sprintf(' %3.3f', sourceMse2))};
%     text(textPosX, textPosY, strMse)
%     
%     % compute the overlap score between scaled estimate and each source
%     % packet
%     [scaledEstimateRepeats(1, :), scaledEstimateRepeats(2, :), scaledEstimateRepeats(3, :)] = ...
%           findRepeats(scaledSourceEstimate(src_it, :));
%     overlapScoreSource1 = computeOverlap(sourceRepeats1, scaledEstimateRepeats);
%     overlapScoreSource2 = computeOverlap(sourceRepeats2, scaledEstimateRepeats);
%     strOverlapScore = {strcat('overlap w/ s1:', sprintf(' %3i', overlapScoreSource1)), ...
%      strcat('overlap w/ s2:', sprintf(' %3i', overlapScoreSource2))};
%     text(textPosX2, textPosY, strOverlapScore)
% 
%     % compute mutual information between scaled estimate and each source
%     % packet
%     sourceMi1 = mutInfo(scaledSourceEstimate(src_it, :), source(1, :));
%     sourceMi2 = mutInfo(scaledSourceEstimate(src_it, :), source(2, :));
%     strMi = {strcat('mi w/1:', sprintf(' %3.3f', sourceMi1)),...
%      strcat('mi w/2:', sprintf(' %3.3f', sourceMi2))};
%     text(textPosX2 + 25, textPosY + 1, strMi)
% 
%     % compute the percentage of correctly estimated symbols in estimated
%     % signal
%     correctSymbols1 = round(100 * (sum( scaledSourceEstimate(src_it, :) == source(1, :))...
%           / packetLength));
%     correctSymbols2 = round(100 *(sum( scaledSourceEstimate(src_it, :) == source(2, :))...
%           / packetLength));
%     strCorrectSymbols = {strcat('% correct symb. w/ s1:', sprintf(' %3i', correctSymbols1)), ...
%       strcat('% correct symb. w/ s2:', sprintf(' %3i', correctSymbols2))};
%     text(textPosX - 30, textPosY + 1, strCorrectSymbols)
%     
%     figureNumber = figureNumber + 1;    
%     clear scaledEstimateRepeats;
%     clear correctSymbols2 correctSymbols1;
%     
% end
% 
% %% compare scaling search results to mi maximization and msi minimization
% % find the scalar scaling factor which minimizes MSE
errorFunc = @immse;
[scalingFactorMse, minMse, scaledSourceEstimateMse] = ...
  findMinMseScalingFactor(source, icaEstimate, base, degree, field, errorFunc, false, icaAlgo);

% find the scalar scaling factor which minimizes MI
errorFunc = @mae;
[scalingFactorMi, minMi, scaledSourceEstimateMi] = ...
  findMinMseScalingFactor(source, icaEstimate, base, degree, field, errorFunc, false, icaAlgo);

%% Plotted comparison of signals
figureNumber = 1;
numComparedSignals = 2;
textPosY = textPosY + 2;
%% plot optimization results using scaling factors

figure('Name', 'signal optimization using scaling factors');
for src_it = 1 : numSources

  subplot(numComparedSignals * numSources, 1, figureNumber);
  plot(1: plotLength, scaledSourceEstimateMse(src_it, 1:plotLength)); 
  title(strcat('minimal MSE scaled signal ', int2str(src_it)));
  % compute the mse between the estimate and each of the source packets
  sourceMse1 = immse(scaledSourceEstimateMse(src_it, :), source(1, :));
  sourceMse2 = immse(scaledSourceEstimateMse(src_it, :), source(2, :));
  strMse = {strcat('src 1:', sprintf(' %3.3f', sourceMse1)), strcat('src 2:', sprintf(' %3.3f', sourceMse2))};
  text(textPosX, textPosY, strMse)

% compute the percentage of correctly estimated symbols in estimated signal
  correctSymbols1 = round(100 * (sum( scaledSourceEstimateMse(src_it, :) == source(1, :))...
        / packetLength));
  correctSymbols2 = round(100 *(sum( scaledSourceEstimateMse(src_it, :) == source(2, :))...
        / packetLength));
  strCorrectSymbols = {strcat('% correct symb. w/ s1:', sprintf(' %3.3f', correctSymbols1)), ...
    strcat('% correct symb. w/ s2:', sprintf(' %3.3f', correctSymbols2))};
  text(textPosX2, textPosY, strCorrectSymbols)


  figureNumber = figureNumber + 1;    
    
  subplot(numComparedSignals * numSources, 1, figureNumber);
  plot(1: plotLength, scaledSourceEstimateMi(src_it, 1:plotLength)); 
  title(strcat('maximum MI scaled signal ', int2str(src_it)));
  % compute the mi between the estimate and each of the source packets
  sourceMi1 = mutInfo(scaledSourceEstimateMi(src_it, :), source(1, :));
  sourceMi2 = mutInfo(scaledSourceEstimateMi(src_it, :), source(2, :));
  strMi = {strcat('src 1:', sprintf(' %3.3f', sourceMi1)), strcat('src 2:', sprintf(' %3.3f', sourceMi2))};
  text(textPosX, textPosY, strMi)
    
  % compute the percentage of correctly estimated symbols in estimated
  % signal
  correctSymbols1 = round(100 * (sum( scaledSourceEstimateMi(src_it, :) == source(1, :))...
        / packetLength));
  correctSymbols2 = round(100 *(sum( scaledSourceEstimateMi(src_it, :) == source(2, :))...
        / packetLength));
  strCorrectSymbols = {strcat('% correct symb. w/ s1:', sprintf(' %3.3f', correctSymbols1)), ...
    strcat('% correct symb. w/ s2:', sprintf(' %3.3f', correctSymbols2))};
  text(textPosX2, textPosY, strCorrectSymbols)

  figureNumber = figureNumber + 1;
       
end

%% print scaling factors
% print minimal MSE scaling factors results
fprintf("minimal MSE scaling factor\n");
disp(scalingFactorMse);

% print maximum MI scaling factors
fprintf("maximum MI scaling factor\n");
disp(scalingFactorMi);

% print maximum overlap scaling factors
fprintf("maximum overlap scaling factors\n");
disp(scalingFactor);