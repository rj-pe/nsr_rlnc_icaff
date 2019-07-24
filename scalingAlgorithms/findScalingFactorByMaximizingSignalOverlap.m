% search for the scaling factor which maximizes the overlap of signal
% segments containing neighboring repetitions.
function [bestScalingFactor, bestScore, scaledSourceEstimate] = ...
 findScalingFactorByMaximizingSignalOverlap( ...
  source, icaEstimate, base, degree, field, plotBool, icaAlgo)

alphabetSize = base^degree;
numSources = size(source, 1);
rowLength = size(source, 2);

% row 1 : start of repetitions
% row 2 : end of repetitions
% row 3 : value repeated
  
% TODO : how to handle multiple pages of repeats results?
% dim 1 corresponds to the scaling factors
% dim 2 corresponds to original source signals 
% dim 3 corresponds to ICA estimated signals

allScalingFactors = zeros(alphabetSize - 1, numSources, numSources);

% construct test signals and test repetition overlap with source
for iterIcaSrc = 1 : numSources % loop through ICA sources
  for iterScalFact = 1 : (alphabetSize - 1) % loop though scaling factors
    % build test signal
    testSignal = zeros(1, rowLength);
    % element-wise multiplication of ICA source by scaling coefficient
    testSignal(1, :) = ...
        vecMultGf(iterScalFact, icaEstimate(iterIcaSrc, :), field, icaAlgo);
    % find the repeating sections of the test signal
    [testRepeats(1, :), testRepeats(2, :), testRepeats(3, :)] = ...
          findRepeats(testSignal);

    % TODO: note that reference to the source signal should be replaced
    %       with reference to a pre-compiled dictionary of common network 
    %       packet characteristics. 
    
    % measure the overlap between the test signal and each of the references
    for iterSrc = 1 : numSources % loop through original sources
     [sourceRepeats(1, :), sourceRepeats(2, :), sourceRepeats(3, :)] = ...
       findRepeats(source(iterSrc, :));

      allScalingFactors(iterScalFact, iterSrc, iterIcaSrc) = ...
       computeOverlap(sourceRepeats, testRepeats);
      clear sourceRepeats;
    end % end loop through original sources
    clear testRepeats
  end % end loop through scaling factors
end % end loop through ICA sources

% pick the maximum overlap scores for each original source
% store the scaling coefficient associated with the score 
[maxValues, maxCoeffs] = max(reshape(allScalingFactors(:, 1, :), [], 2));
[max1, src1] = max(maxValues);
maxCoeff1 = maxCoeffs(src1);

% pick the maximum value from the other estimated source
column = 2;
src2 = numSources - mod(src1 + 1, 2);
[max2, maxCoeff2] = max(allScalingFactors(:, column, src2));

bestScore = max1 + max2;

bestScalingFactor(src1) = maxCoeff1;
bestScalingFactor(src2) = maxCoeff2;

scaledSourceEstimate = zeros(numSources, size(source, 2));
scaledSourceEstimate(src1, :) = vecMultGf(maxCoeff1, icaEstimate(src1, :), field, icaAlgo);
scaledSourceEstimate(src2, :) = vecMultGf(maxCoeff2, icaEstimate(src2, :), field, icaAlgo);

%% plotting scores for each factor
% each plot shows the correlation between the 
% product of an estimated source and set of scaling factors
% and a source signal
if plotBool
	figure('Name', 'overlapScore(estimated source, original signal) for scaling factors');

	subplot(4, 1, 1);
	source1est1OverlapScores = reshape(allScalingFactors(:, 1, 1), 1, []);
	plot(source1est1OverlapScores)
	title('scaling factor source 1 est 1');

	subplot(4, 1, 2);
	source1est2OverlapScores = reshape(allScalingFactors(:, 1, 2), 1, []);
	plot(source1est2OverlapScores)
	title('scaling factor source 1 est 2');

	subplot(4, 1, 3);
	source2est1OverlapScores = reshape(allScalingFactors(:, 2, 1), 1, []);
	plot(source2est1OverlapScores)
	title('scaling factor source 2 est 1');

	subplot(4, 1, 4);
	source2est2OverlapScores = reshape(allScalingFactors(:, 2, 2), 1, []);
	plot(source2est2OverlapScores)
	title('scaling factor source 2 est 2');
end