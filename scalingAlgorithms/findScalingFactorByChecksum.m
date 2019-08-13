function [scalingFactor, scaledSourceEstimate] = ...
  findScalingFactorByChecksum(estimatedSource, base, degree, field, icaAlgo)

% scale the estimate and pick the factor that produces a correct checksum

alphabetSize = base^degree;
numSources = size(estimatedSource, 1);
rowLength = size(estimatedSource, 2);

results = zeros(alphabetSize, numSources);
scalingFactor = zeros(numSources, 1);

% for each ICA output run the scaling search algorithms
for iterEstSrc = 1 : numSources
    % for each membber of the alphabet construct a test packet
    for iterSclCoeff = 1 : alphabetSize - 1    
        % for each information type run a scaling factor search
        testSource = zeros(1, rowLength);
        testSource(1,:) = ...
            vecMultGf(iterSclCoeff, estimatedSource(iterEstSrc, :), field, icaAlgo);
        % check the IPv4 checksum of the scaled estimate 
        results(iterSclCoeff, iterEstSrc) = verifyIPv4Checksum(testSource);
    end
end

if size(find(results(:, 1), 1)) > 0
    % pick the scaling coefficient which results in a correct checksum
    scalingFactor(1,1) = find(results(:, 1), 1);
else
    scalingFactor(1,1) = 1;
end

if size(find(results(:, 2), 1)) > 0
    scalingFactor(2,1) = find(results(:, 2), 1);
else
    scalingFactor(2,1) = 1;
end

% construct the final scaled estimates
scaledSourceEstimate(1,:) = ...
  vecMultGf(scalingFactor(1), estimatedSource(1, :), field, icaAlgo);
scaledSourceEstimate(2,:) = ...
  vecMultGf(scalingFactor(2), estimatedSource(2, :), field, icaAlgo);
