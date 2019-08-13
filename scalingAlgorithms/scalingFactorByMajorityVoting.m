function [scalingFactor, scaledSourceEstimate] = ...
  scalingFactorByMajorityVoting(...
    information, infoUnits, estimatedSource, base, degree, field, icaAlgo)

% run each scaling algorithm and pick the one that returns a correct checksum
% infoUnits stores the number of meaningful entries of each page in information

alphabetSize = base^degree;
numSources = size(estimatedSource, 1);
rowLength = size(estimatedSource, 2);

% information container has a page for each type of prior knowledge
numInformationTypes = size(information, 3);
numInformationUnits = size(information, 2);
numInformationTotal = numInformationTypes * numInformationUnits;

% results container has an entry for each combination of 
% information coordinate (row and page) and scaling factor
results = ...
  zeros(numInformationUnits, numSources, alphabetSize, numInformationTypes);

% for each ICA output run the scaling search algorithms
for iterEstSrc = 1 : numSources
    % for each member of the alphabet construct a test packet
    for iterSclCoeff = 1 : alphabetSize - 1    
        testSource = zeros(1, rowLength);
        testSource(1,:) = ...
            vecMultGf(...
              iterSclCoeff, estimatedSource(iterEstSrc, :), field, icaAlgo);
        % for each information type run a scaling factor search
        for iterInfoType 1 : numInformationTypes
            % for each unit of information present in the information type list
            for iterInfoUnit = 1 : infoUnits(iterInfoType)
            % check the current test source for a match
            results(iterInfoUnit, iterEstSrc, iterSclCoeff, iterInfoType) = ...
              any(...
                strfind(testSource, information(iterInfoType,iterInfoUnit,:)));
            end % iterInfoUnit
        end % iterInfoType
    end % iterSclCoeff
end % iterEstSrc

% reshape the results for the first source and pick the coefficient with 
% the longest matching sequence

[value, coeff] = max( reshape( results(:, 1, :, :), [], numInformationTotal));
[one, matchIdx] = max( value);
scalingFactor(1) = coeff( matchIdx);

clearvars value coeff one matchIdx

% reshape the results for the second source and pick the coefficient with 
% the longest matching sequence
[value, coeff] = max( reshape( results(:, 2, :, :), [], numInformationTotal));
[one, matchIdx] = max( value);
scalingFactor(2) = coeff( matchIdx);

scaledSourceEstimate = zeros(numSources, rowLength);
scaledSourceEstimate(1,:) = ...
  vecMultGf(scalingFactor(1), estimatedSource(1,:), field, icaAlgo);
scaledSourceEstimate(2,:) = ...
  vecMultGf(scalingFactor(2), estimatedSource(2,:), field, icaAlgo);

end % function
