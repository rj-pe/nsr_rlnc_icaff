function[scalingFactor, ipAddressMatch, scaledSourceEstimate] = ...
 findScalingFactorByIpAddressMatching(ipAddress, estimatedSource, base, degree, field, plotBool, icaAlgo)

alphabetSize = base^degree;
numSources = size(estimatedSource, 1);
rowLength = size(estimatedSource, 2);

numAddresses = size(ipAddress, 1);

allScalingFactors = zeros(alphabetSize - 1, numSources, numAddresses);

for iterEstSrc = 1 : numSources
  for iterSclCoeff = 1 : (alphabetSize - 1)
    % scale each ICA estimate
    testSource = zeros(1, rowLength);
    testSource(1, :) = ...
      vecMultGf(iterSclCoeff, estimatedSource(iterEstSrc, :), field, icaAlgo);
    for iterAddr = 1 : numAddresses
        % check the scaled ICA estimate for an IP address match
        % TODO: consider taking smaller slices of the IP address and matching
        % those
        allScalingFactors(iterSclCoeff, iterEstSrc, iterAddr) = ...
         any(strfind(testSource, ipAddress(iterAddr, :)));
    end
  end
end

[value, coeff] = max( reshape( allScalingFactors(:, 1, :), [], numAddresses));
[one, matchIdx] = max( value);

ipAddressMatch(1,:) = ipAddress( matchIdx, :);
scalingFactor(1) = coeff( matchIdx);

clearvars value coeff one matchIdx

[value, coeff] = max( reshape( allScalingFactors(:, 2, :), [], numAddresses));
[one, matchIdx] = max( value);

ipAddressMatch(2,:) = ipAddress( matchIdx, :);
scalingFactor(2) = coeff( matchIdx);

scaledSourceEstimate = zeros(numSources, rowLength);
scaledSourceEstimate(1, :) = vecMultGf(scalingFactor(1), estimatedSource(1, :), field, icaAlgo);
scaledSourceEstimate(2, :) = vecMultGf(scalingFactor(2), estimatedSource(2, :), field, icaAlgo);

end