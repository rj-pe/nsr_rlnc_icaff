function generateResults(folder)

load(strcat(folder, '/final.mat'));
together = false;
numbers = false;
logy = false;
threeD = false;
percent = true;
algo = 2;

sourceIdx = 1;
estimateIdx = 1;

switch algo 
    case 1
        mse_algorithm = mse_repeatingOverlaps(:, sourceIdx, estimateIdx);
        if percent
            pctBytes = pctBytes_repeatingOverlaps(:, sourceIdx, estimateIdx);
        end
    case 2
        mse_algorithm = mse_mseMinimization(:, sourceIdx, estimateIdx);
        if percent
            pctBytes = pctBytes_mseMinimization(:, sourceIdx, estimateIdx);
        end
    case 3
        mse_algorithm = mse_ipAddressOverlap(:, sourceIdx, estimateIdx);
        if percent
            pctBytes = pctBytes_ipAddressOverlap(:, sourceIdx, estimateIdx);
        end
    case 4
        mse_algorithm = mse_portNumberOverlap(:, sourceIdx, estimateIdx);
        if percent
            pctBytes = pctBytes_portNumberOverlap(:, sourceIdx, estimateIdx);
        end
end
if logy
    mse_algorithm((mse_algorithm == 0)) = 0.01;
end

if size(kldSources,2) > 1
    kldSources = kldSources(:, 1);
end
 
yPos = max(mse_algorithm) + 4;

if numbers
    a = (1 : nPairs)'; b = num2str(a); c = cellstr(b);
else
    circleSize = 20;
%     colors = gradient(mse_algorithm);
end

if threeD
figure;
mseZeros = mse_algorithm == 0;
scatter3(kldSources, mutInfoTestSources, mse_algorithm);
xlabel('kld of sources');
ylabel('mutal information of sources');
zlabel('final MAE');

else
%% plot mutual information of observations versus mse_algorithm

if together
    h(1) = subplot(3, 1, 1);
elseif percent
    figure('Name', 'Percent Bytes Correctly Decoded vs. Mutual Information of Observations',...
    'Units', 'Inches', 'Position', [0 0 13.125 5], 'PaperPositionMode', 'auto');
else
    figure('Name', 'Final MAE vs. mutal information of observations');
end

if numbers
    scatter(mutInfoObservations, mse_algorithm,...
    'MarkerEdgeColor', 'none', 'DisplayName', 'mut info observations' )
    text(mutInfoObservations, mse_algorithm, c);
elseif logy
    scatter(mutInfoObservations, log(mse_algorithm)+1, circleSize, colors);
elseif percent

    %scatter(mutInfoObservations, pctBytes, circleSize, colors);
    scatter(mutInfoObservations, pctBytes, circleSize, ...
              'MarkerEdgeColor',[0 .5 .5],...
              'MarkerFaceColor',[0 .7 .7],...
              'LineWidth',1.5)
else
    scatter(mutInfoObservations, mse_algorithm, circleSize, colors);
end
    
xPos = max(mutInfoObservations) - 0.19 * max(mutInfoObservations);
if percent
    title('Percent Bytes Correctly Decoded vs. Mutal Information of Observations');
    ylabel('percent bytes correct');
else
    text(xPos, yPos, 'Final MAE vs. mutal information of observations');
    ylabel('final MAE');
end

xlabel('Mutal Information of Observations');
print -depsc2 miObs.eps

if together
    h(2) = subplot(3,1,2);
elseif percent
    figure('Name', 'Percent Bytes Correctly Decoded vs. Kullback-Leibler Divergence of Sources',...
        'Units', 'Inches', 'Position', [0 0 13.125 5], 'PaperPositionMode', 'auto');     
else
    figure('Name', 'Final MAE vs. KLD of sources');
end

if numbers
    scatter(kldSources, mse_algorithm,...
    'MarkerEdgeColor', 'none', 'DisplayName', 'kld sources' )
    text(kldSources, mse_algorithm, c); 
elseif logy
    scatter(kldSources, log(mse_algorithm)+1, circleSize, colors);
elseif percent    
    %scatter(kldSources, pctBytes, circleSize, colors);
    scatter(kldSources, pctBytes, circleSize, ...
              'MarkerEdgeColor',[0 .5 .5],...
              'MarkerFaceColor',[0 .7 .7],...
              'LineWidth',1.5)
else
    scatter(kldSources, mse_algorithm, circleSize, colors);
end

xPos = max(kldSources) - 0.15 * max(kldSources);

if percent
    title('Percent Bytes Correctly Decoded vs. Kullback-Leibler Divergence of sources');
    ylabel('Percent Bytes Correct');
else
    text(xPos, yPos, 'Final MAE vs. KLD of sources');
    ylabel('final MAE');
end

xlabel('KLD of Sources');
print -depsc2 kldSources.eps

if together
    h(3) = subplot(3,1,3);
elseif percent
    figure('Name', 'Percent Bytes Correctly Decoded vs. Mutual Information of Sources',...
        'Units', 'Inches', 'Position', [0 0 13.125 5], 'PaperPositionMode', 'auto');  
else
    figure('Name', 'Final MAE vs. mutual information of sources');
end

if numbers
    scatter(mutInfoTestSources, mse_algorithm, ...
    'MarkerEdgeColor', 'none', 'DisplayName', 'mut info sources' )
    text(mutInfoTestSources, mse_algorithm, c);
elseif logy
    scatter(mutInfoTestSources, log(mse_algorithm)+1, circleSize, colors);
elseif percent
      
    %scatter(mutInfoTestSources, pctBytes, circleSize, colors);
    scatter(mutInfoTestSources, pctBytes, circleSize, ...
              'MarkerEdgeColor',[0 .5 .5],...
              'MarkerFaceColor',[0 .7 .7],...
              'LineWidth',1.5)
else
    scatter(mutInfoTestSources, mse_algorithm, circleSize, colors);
end

xPos = max(mutInfoTestSources) - 0.19 * max(mutInfoTestSources);
if percent
    title('Percent Bytes Correctly Decoded vs. Mutual Information of Sources');
    ylabel('Percent Bbytes Correct');
else
    text(xPos, yPos, 'Final MAE vs. mutual information of sources');
    ylabel('final MAE');
end
xlabel('Mutal Information of Sources');
print -depsc2 miSources.eps
%linkaxes(h, 'x');
end
