%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%% packet data processing %%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%{
% store each packet in a matlab array
packets1 = readmatrix('httpWithJpegs.txt','OutputType', 'char');
packets2 = readmatrix('sessionPackets.txt', 'OutputType', 'char');
packets3 = readmatrix('httpOver80211.txt', 'OutputType', 'char');
packets = [packets1; packets2; packets3];
clearvars packets1 packets2 packets3;

% mix up the rows
r = randperm(size(packets, 1));
packets = packets(r, :);

% convert char to hex
packetlen = strlength(packets);
maxPacketLength = max(packetlen);
numPackets = size(packets, 1);

source = zeros(numPackets, maxPacketLength);

for row_idx = 1 : numPackets
  for str_idx = 1 : packetlen(row_idx)
      source(row_idx, str_idx) = hex2dec(packets{row_idx}(str_idx));
    end
end
save(string(numPackets));
%}

%% define test parameters

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%% test parameters  %%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

load('28388.mat');
load('ipAddresses');

% pick packet pairs from list of packets
numTests = 10000;
zerosThreshold = 0.8;

% specify the separation test parameters
nPairs = 1000;

% specify the number of scaling algorithms used
% algorithm 1 = findFactorByChecksum.m
% algorithm 2 = findMinMseScalingFactor.m
numAlgos = 2;

% sorts by mse of observations for blind testing
% sorts by mse of original sources otherwise
blindTest = true;

% define the metric used for choosing pairs to separate
%metric = 'kld';
metric = 'mi';

% define the way in which error is measured
% mean squared error
errorFunc = @immse;

% mean absolute error
%errorFunc = @mae;

% separate only non-zero mi/kld values if true
excludeZeros = false;

% which ica algorithm to use for separation
icaAlgo =  'AMERICA';
binICA = false;

%% choose N pairs with lowest MI/KLD

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% pick random packet groupings %
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% choose N pairs from the packet list
pairIdx = randi([1, numPackets], numTests, 2);
testPairs = zeros(numTests, maxPacketLength, 2);
testPairs(:, :, 1) = source(pairIdx(:, 1), :);
testPairs(:, :, 2) = source(pairIdx(:, 2), :);

% instantiate some variables needed for ica
base = 2;
degree = 4;
% Construct list of finite field elements
field = gftuple((-1:base^degree-2)', degree, base);

% for KLD testing
% create a uniform probability mass function for ff elements
alphabetSize = base^degree;
alphabet = 0 : alphabetSize-1;
uniformProb = 1 / alphabetSize;
uniform = ones(1, alphabetSize) .* uniformProb;

% instantiate containers for testing of packet pairs
mixingMatrix = zeros(2, 2, numTests);

if strcmp(metric, 'mi')
  testMutInfos = zeros(numTests, 1);
elseif strcmp(metric, 'kld')
  testKLD = zeros(numTests, 2);
end


%% begin test on packet pairs
for iterTest = 1 : numTests
    [testSource, testSourceLength] = ...
                        createTestSource(iterTest, pairIdx, source, packetlen);

  %TODO: candidate for function modularization
    % skip pairings which contain packets which contain more than zerosThreshold
    % percent of zeros
    if ( 1 - nnz(testSource(1,:)) / testSourceLength(1) > zerosThreshold ) || ...
            ( 1 - nnz(testSource(2,:)) / testSourceLength(1) > zerosThreshold )
        % mark the appropriate measures as Inf
        if strcmp(metric, 'mi')
            testMutInfos(iterTest) = Inf;
        elseif strcmp(metric, 'kld')
            testKLD(iterTest, 1) = Inf;
            testKLD(iterTest, 2) = Inf;
        end
        % skip the rest of the test
        continue;
    end % check for zeros threshold

    % run the pair of packets through network coding
    [observations, mixingMatrix(:,:, iterTest)] = networkCoding(testSource, base, degree);

    if strcmp(metric, 'mi')
        % measure the mutual information between the two packets
        if blindTest
            testMutInfos(iterTest) = mutInfo(observations(1, :), observations(2, :));
        else
            testMutInfos(iterTest) = mutInfo(testSource(1, :), testSource(2, :));
        end % blind condition

    %TODO: candidate for function modularization
    elseif strcmp(metric, 'kld')
        % measure the kullback-leibler divergence of each packet
        if blindTest
            % calculate pmf of each packet in pair
            pmfObservation1 = fitPmf2Source(observations(1,:))';
            pmfObservation2 = fitPmf2Source(observations(2,:))';

            % calculate the KLD between each packet and a uniform distribution
            testKLD(iterTest, 1) = kldiv(alphabet, pmfObservation1, uniform);
            testKLD(iterTest, 2) = kldiv(alphabet, pmfObservation2, uniform);
        else
            % calculate pmf of each packet in pair
            pmfSource1 = fitPmf2Source(testSource(1,:))';
            pmfSource2 = fitPmf2Source(testSource(2,:))';

            % calculate the KLD between each packet and a uniform distribution
            testKLD(iterTest, 1) = kldiv(alphabet, pmfSource1, uniform);
            testKLD(iterTest, 2) = kldiv(alphabet, pmfSource2, uniform);
        end % blind condition

    end % choose metric

    clearvars testSource observations;
end

%% sort the pairs according to chosen metric
if strcmp(metric, 'mi')
    [mis, chosenPairsIdx] = sort(testMutInfos);
elseif strcmp(metric, 'kld')
    [rowIdx, colIdx, values] = find(testKLD(:, 1) + testKLD(:, 2));
    [mis, chosenPairsIdx] = sort(values);
    chosenPairsIdx = rowIdx(chosenPairsIdx);
end

% create containers for columns in results table
% test characteristics
if blindTest
    blindStr = 'obs';
else
    blindStr = 'src';
end
time = datetime('now');
datestring = strrep(datestr(time), ' ', '_');
testName = sprintf('%s_%s_%s_%.3f---%.3f_%d-pairs_%s', ...
    icaAlgo, metric, blindStr, mis(1), mis(nPairs), nPairs, datestring);
testName = strrep(testName, '.','-');
mkdir(testName);

packetPairName = strings(nPairs, 1);
lengthPacket1 = zeros(nPairs, 1);
lengthPacket2 = zeros(nPairs, 1);
kldSources = zeros(nPairs, 3);
mutInfoTestSources = zeros(nPairs, 1);
mutInfoObservations = zeros(nPairs, 1);
mse_IcaEstimate = zeros(nPairs, 2, 2);

% results for ipv4 checksum algorithm
pctBytes_ipv4Checksum = zeros(nPairs, 2, 2);
pctNibbles_ipv4Checksum = zeros(nPairs, 2, 2);
pctBits_ipv4Checksum = zeros(nPairs, 2, 2);
mse_ipv4Checksum = zeros(nPairs, 2, 2);
scalingFactors_ipv4Checksum = zeros(nPairs, 2);
ipv4checksum_ipv4Checksum = zeros(nPairs, 2);

% results for mse minimization algorithm
pctBytes_mseMinimization = zeros(nPairs, 2, 2);
pctNibbles_mseMinimization = zeros(nPairs, 2, 2);
pctBits_mseMinimization = zeros(nPairs, 2, 2);
mse_mseMinimization = zeros(nPairs, 2, 2);
scalingFactors_mseMinimization = zeros(nPairs, 2);
ipv4checksum_mseMinimization = zeros(nPairs, 2);

idxNzOffset = 0;
%% run separation on the N pairs with the lowest MI/KLD for separation
for pairIter = 1 : nPairs

    if excludeZeros && pairIter == 1
        % if we want to exclude MI/KLD which are equal to zero
        idxNzOffset = find(mis, 1, 'first');
        testIdx = chosenPairsIdx(pairIter + idxNzOffset);
    else
        testIdx = chosenPairsIdx(pairIter + idxNzOffset);
    end

    [testSource, testSourceLength, testSourceIdx] = ...
      createTestSource(testIdx, pairIdx, source, packetlen);
    lengthPacket1(pairIter) = testSourceLength(2);
    lengthPacket2(pairIter) = testSourceLength(3);

    % calculate pmf of each packet in pair
    pmfSource1 = fitPmf2Source(testSource(1,:))';
    pmfSource2 = fitPmf2Source(testSource(2,:))';
    % calculate the KLD between each packet and a uniform distribution
    testKLD1 = kldiv(alphabet, pmfSource1, uniform);
    testKLD2 = kldiv(alphabet, pmfSource2, uniform);
    kldSources(pairIter,1) = kldiv(alphabet, pmfSource1, uniform);
    kldSources(pairIter,2) = kldiv(alphabet, pmfSource2, uniform);

    mutInfoTestSources(pairIter) = mutInfo(testSource(1, :), testSource(2, :));

    testMixingMatrix = mixingMatrix(:,:, testIdx);

    observationsGf =  gf(testMixingMatrix, degree) * gf(testSource, degree);
    observations = gf2mat(observationsGf);
    mutInfoObservations(pairIter) = mutInfo(observations(1,:), observations(2, :));


    % run ica on observations
    %%%%%%%%%%%%%%%%%%%%
    % AMERICA separation
    %%%%%%%%%%%%%%%%%%%%

    if strcmp(icaAlgo, 'AMERICA')
     [icaEstimate]  = ica(observations, testMixingMatrix, testSourceLength, ...
                          base, degree, binICA);
    end
    % end AMERICA

    for mseIcaEstIdx  = 1 : 2
        for mseSourceIdx = 1 : 2
            mse_IcaEstimate(pairIter, mseIcaEstIdx, mseSourceIdx) = ...
             errorFunc(icaEstimate(mseIcaEstIdx, :), testSource(mseSourceIdx, :));
        end
    end

    % save the workspace variables of interest
    workspace_name = sprintf('%i__%i__%.2f', ...
        testSourceIdx(1), testSourceIdx(2), mutInfo(testSource(1,:), testSource(2,:)));
    workspace_name = strrep(workspace_name, '.','-');
    disp(workspace_name);
    packetPairName(pairIter) = workspace_name;
    save(strcat(testName, '/', workspace_name),...
        'testSource', 'observations', 'testMixingMatrix', 'icaEstimate');

    % run scaling search algorithms on the separation results
    for iterAlgo = 1 : numAlgos

        scaledSourceEstimate = zeros(testSourceLength(1));
        mse_algo = zeros(2);
        pctBytes = zeros(2);
        pctNibbles = zeros(2);
        pctBits = zeros(2);
        ipv4checksum = zeros(1,2);

        switch iterAlgo
            case 1
                % ipv4 checksum
                [scalingFactors_ipv4Checksum(pairIter,:), ...
                  scaledSourceEstimate] = ...
                findFactorByChecksum(icaEstimate, base, degree, field, icaAlgo);
            case 2
                % mse minimization
                [scalingFactors_mseMinimization(pairIter, :), bestScore, scaledSourceEstimate] = ...
                 findMinMseScalingFactor(...
                    testSource, icaEstimate, base, degree, field, errorFunc, false, icaAlgo
         end % end switch

         % evaluate the results of the separation and scaling
        [mse_algo, pctBytes, pctNibbles, pctBits, ipv4checksum] = ...
            evaluateSeparationResults(...
              scaledSourceEstimate, testSource, errorFunc);

        % save the results
        switch iterAlgo
            case 1
                mse_ipv4Checksum(pairIter,:,:) = mse_algo;
                pctBytes_ipv4Checksum(pairIter,:,:) = pctBytes;
                pctNibbles_ipv4Checksum(pairIter, :,:) = pctNibbles;
                pctBits_ipv4Checksum(pairIter,:,:) = pctBits;
                ipv4checksum_ipv4Checksum(pairIter,:) = ipv4checksum;
            case 2
                mse_mseMinimization(pairIter,:,:) = mse_algo;
                pctBytes_mseMinimization(pairIter,:,:) = pctBytes;
                pctNibbles_mseMinimization(pairIter, :,:) = pctNibbles;
                pctBits_mseMinimization(pairIter,:,:) = pctBits;
                ipv4checksum_mseMinimization(pairIter,:) = ipv4checksum;
        end % end switch

        clearvars scaledSourceEstimate pctBits pctNibbles pctBytes mse_algo;
    end % switch for scaling algos tests
    kldSources(:,3) = kldSources(:,1) + kldSources(:,2);
end % pairs testing


%% summarize the results for each scaling search algorithm
for iterAlgo = 1 : numAlgos
    switch iterAlgo
        case 1
            mse_algo = mse_ipv4Checksum;
            pctBytes = pctBytes_ipv4Checksum;
            pctNibbles = pctNibbles_ipv4Checksum;
            pctBits = pctBits_ipv4Checksum;
            scalingFactors = scalingFactors_ipv4Checksum;
            ipv4checksum = ipv4checksum_ipv4Checksum;
            figName = 'ipv4_checksum';
        case 2
            mse_algo = mse_mseMinimization;
            pctBytes = pctBytes_mseMinimization;
            pctNibbles = pctNibbles_mseMinimization;
            pctBits = pctBits_mseMinimization;
            scalingFactors = scalingFactors_mseMinimization;
            ipv4checksum = ipv4checksum_mseMinimization;
            figName = 'MSE_minimization';
    end %end switch

    % TODO: include delta mse
    T = table(...
                    packetPairName,...
                    lengthPacket1,...
                    lengthPacket2,...
                    kldSources(:,1),...
                    kldSources(:,2),...
                    kldSources,...
                    mutInfoTestSources,...
                    mutInfoObservations,...
                    mse_IcaEstimate(:,1,1),...
                    mse_IcaEstimate(:,1,2),...
                    mse_IcaEstimate(:,2,1),...
                    mse_IcaEstimate(:,2,2),...
                    scalingFactors(:,1),...
                    scalingFactors(:,2),...
                    mse_algo(:,1,1),...
                    mse_algo(:,1,2),...
                    mse_algo(:,2,1),...
                    mse_algo(:,2,2),...
                    ipv4checksum(:,1),...
                    ipv4checksum(:,2),...
                    pctBytes(:,1,1),...
                    pctBytes(:,1,2),...
                    pctBytes(:,2,1),...
                    pctBytes(:,2,2),...
                    pctNibbles(:,1,1),...
                    pctNibbles(:,1,2),...
                    pctNibbles(:,2,1),...
                    pctNibbles(:,2,2),...
                    pctBits(:,1,1),...
                    pctBits(:,1,2),...
                    pctBits(:,2,1),...
                    pctBits(:,2,2)...
    );
    %uit.Data = d;
    T.Properties.VariableNames = {...
                    'name',...
                    'len_s1',...
                    'len_s2',...
                    'kld_s1',...
                    'kld_s2',...
                    'kld_s1_s2',...
                    'mi_s1_s2',...
                    'mi_x1_x2',...
                    'mse_ica1_s1',...
                    'mse_ica1_s2',...
                    'mse_ica2_s1',...
                    'mse_ica2_s2',...
                    'factor1',...
                    'factor2',...
                    'mse_a1_s1',...
                    'mse_a1_s2',...
                    'mse_a2_s1',...
                    'mse_a2_s2',...
                    'checksum_a1',...
                    'checksum_a2',...
                    'pct_byt_a1_s1',...
                    'pct_byt_a1_s2',...
                    'pct_byt_a2_s1',...
                    'pct_byt_a2_s2',...
                    'pct_nib_a1_s1',...
                    'pct_nib_a1_s2',...
                    'pct_nib_a2_s1',...
                    'pct_nib_a2_s2',...
                    'pct_bit_a1_s1',...
                    'pct_bit_a1_s2',...
                    'pct_bit_a2_s1',...
                    'pct_bit_a2_s2',...
                    };
    T.Properties.Description = figName;
    writetable(T, strcat(testName, '/', figName, ".csv"));
    clearvars msealgo pctBytes pctNibbles pctBits scalingFactors figName ipv4checksum;
end % results summary

save(strcat(testName, '/', 'final'));
