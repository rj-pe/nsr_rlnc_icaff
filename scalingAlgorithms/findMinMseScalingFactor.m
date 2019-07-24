function[scalingFactor, minCorr, scaledSourceEstimate] = ...
	findMinMseScalingFactor(source, estimatedSource, base, degree, field, errorFunc, plotBool, icaAlgo)

if strcmp(func2str(errorFunc), 'immse')
	corrMeasure = @immse;
    optFunc = @min;
    strTitle = 'mse';
elseif strcmp(func2str(errorFunc), 'mutInfo')
	corrMeasure = @mutInfo;
    optFunc = @max;
    strTitle = 'mi';
elseif strcmp(func2str(errorFunc), 'mae')
    corrMeasure = @mae;
    optFunc = @min;
    strTitle = 'mae';
end


alphabetSize = base^degree;
numSources = size(source, 1);
rowLength = size(source, 2);

%% container to hold potential scaling factors
% dim1 corresponds to a scaling factor
% dim2 corresponds to correlation scores for an estimated source
% dim3 corresponds to correlation scores for an original source
allScalingFactors = zeros(alphabetSize-1, numSources, numSources);

for iterEstSrc = 1 : numSources
% generate scaled signal for each combination of scaling factor & estimated signal
	for iterSclCoeff = 1 : (alphabetSize -1)
		% build the test signal
		testSource = zeros(1, rowLength);
		% elementwise multiplication of est. source by scaling coefficient
		testSource(1, :) = ...
			vecMultGf(iterSclCoeff, estimatedSource(iterEstSrc, :), field, icaAlgo);
        
		% measure correlation between the test signal and each of the sources
		% store each correlation result in the row corresponding to its factor
		for iterSource = 1 : numSources
			allScalingFactors(iterSclCoeff, iterSource, iterEstSrc) = ...
			  corrMeasure((testSource + 1), (source(iterSource, :) + 1));
		end
	end
end

% pick the minimum value from the estimated source 
% while keeping track of the associated coefficient
[minValues, minCoeffs] = optFunc(reshape(allScalingFactors(:, 1, :), [], 2));
[min1, src1] = optFunc(minValues);
minCoeff1 = minCoeffs(src1);
% pick the minimum value from the other estimated source
column = 2;
src2 = numSources - mod(src1 + 1, 2);
[min2, minCoeff2] = optFunc(allScalingFactors(:, column, src2));
% calculate the sum of correlation scores that results from this pick
minCorr = min1 + min2;

scalingFactor(src1) = minCoeff1;
scalingFactor(src2) = minCoeff2;

scaledSourceEstimate = zeros(numSources, size(source, 2));
scaledSourceEstimate(src1, :) = vecMultGf(minCoeff1, estimatedSource(src1, :), field, icaAlgo);
scaledSourceEstimate(src2, :) = vecMultGf(minCoeff2, estimatedSource(src2, :), field, icaAlgo);

if plotBool
%% plotting correlations
% each plot shows the correlation between the 
% product of an estimated source and set of scaling factors
% and a source signal
	figure('Name', 'mse(estimated source, original signal) for scaling factors');

	subplot(4, 1, 1);
	source1est1mse = reshape(allScalingFactors(:, 1, 1), 1, []);
	plot(source1est1mse)
	title(strcat('scaling factor source 1 est 1', strTitle));

	subplot(4, 1, 2);
	source1est2mse = reshape(allScalingFactors(:, 1, 2), 1, []);
	plot(source1est2mse)
	title(strcat('scaling factor source 1 est 2', strTitle));

	subplot(4, 1, 3);
	source2est1mse = reshape(allScalingFactors(:, 2, 1), 1, []);
	plot(source2est1mse)
	title(strcat('scaling factor source 2 est 1', strTitle));

	subplot(4, 1, 4);
	source2est2mse = reshape(allScalingFactors(:, 2, 2), 1, []);
	plot(source2est2mse)
	title(strcat('scaling factor source 2 est 2', strTitle));
end

end % function findMinScalingFactor
