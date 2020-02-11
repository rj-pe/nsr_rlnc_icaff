function [scalingFactor, scaledSourceEstimate] = ...
  findScalingFactorByChecksum(estimatedSource, base, degree, field, icaAlgo)

% scale each packet estimate and pick the factor that produces a correct chksum

alphabetSize = base^degree;
numSources = size(estimatedSource, 1);
rowLength = size(estimatedSource, 2);

results = zeros(alphabetSize, numSources);
scalingFactor = zeros(numSources, 1);

% for each ICA output run the scaling search algorithm
for iterEstSrc = 1 : numSources
  % for each member of the alphabet construct a test packet
  for iterSclCoeff = 1 : alphabetSize - 1    
    % construct a test source (only the ipv4 checksum section of the packet)
    testSource = zeros(1, 40);
    testSource(1,:) = ...
      vecMultGf(iterSclCoeff, estimatedSource(iterEstSrc, 29:68), field, degree, icaAlgo);
    % check & store the IPv4 checksum of the scaled estimate 
    results(iterSclCoeff, iterEstSrc) = verifyIPv4Checksum(testSource, 1);
  end
end

% for each packet pick the scaling factor which resulted in a correct chksum
for iterSrc = 1 : numSources
  if size(find(results(:, iterSrc), 1)) > 0
    % success! store the correct scaling factor
    scalingFactor(iterSrc,1) = find(results(:, iterSrc), 1);
  else
    % no such scaling coefficient found, store 1
    scalingFactor(iterSrc,1) = 1;
  end
end

%if size(find(results(:, 2), 1)) > 0
%  scalingFactor(2,1) = find(results(:, 2), 1);
%else
%  scalingFactor(2,1) = 1;
%end

% construct the final scaled estimates
for iterSrc = 1 : numSources
  scaledSourceEstimate(iterSrc,:) = ...
    vecMultGf(scalingFactor(iterSrc), estimatedSource(iterSrc, :), field, degree, icaAlgo);
end  

%scaledSourceEstimate(2,:) = ...
%  vecMultGf(scalingFactor(2), estimatedSource(2, :), field, icaAlgo);

