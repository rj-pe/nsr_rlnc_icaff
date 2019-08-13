% extract the raw packet data from a pcapng file
% uses awk to filter packets which are shorter than 1000
% tshark -r packetName.pcapng -T jsonraw | egrep "frame_raw" | awk 'length($0)>1000' | awk '{print $2}' | sed 's/\[//' | sed 's/\"//' | sed 's/\"\,//'
% tshark -r packetName.pcapng -T jsonraw | egrep "frame_raw" | awk '{print $2}' | sed 's/\[//' | sed 's/\"//' | sed 's/\"\,//'
% filter out the ip address numbers from a wireshark list of resolved addresses
% cat ipAddressesList |  awk {'print $4'} | sed 's/,//' | sed 's/\./ /g' | sed 's/[0-9]/ & /g' > ipList
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

%% choose N pairs with lowest MI/KLD

load('data/28388.mat');
load('data/ipAddresses');

% pick packet pairs from list of packets
numTests = 10000;
zerosThreshold = 0.8;

% specify the separation test parameters
nPairs = 1000;
numAlgos = 4;

% sorts by mse of observations for blind testing
% sorts by mse of original sources otherwise
blindTest = true;

% define the metric used for choosing pairs to separate
%metric = 'maxkld';
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
%icaAlgo = 'cobICA';

icaAlgo =  'AMERICA';
binICA = false;

% choose N pairs from the packet list
pairIdx = randi([1, numPackets], numTests, 2);
testPairs = zeros(numTests, maxPacketLength, 2);
testPairs(:, :, 1) = source(pairIdx(:, 1), :);
testPairs(:, :, 2) = source(pairIdx(:, 2), :);

% instantiate some variables needed for ica
base = 2;
degree = 4;
field = gftuple((-1:base^degree-2)', degree, base); % Construct list of elements.
% for cobICA
%non-uniformity threshold
thre = 0.2;         
% struct with some parameters of cobICA
pm = struct('nCLmax',10,'nCLmin',2,'sigmas',.1,'C0',1,'maxEpoch',300);
RandStream.setGlobalStream(RandStream('mt19937ar','seed',sum(clock)));

% for KLD testing
alphabetSize = base^degree;
alphabet = 0 : alphabetSize-1;
uniformProb = 1 / alphabetSize;
uniform = ones(1, alphabetSize) .* uniformProb;


% instantiate containers for testing of packet pairs
mixingMatrix = zeros(2, 2, numTests);

if strcmp(metric, 'mi')
    testMutInfos = zeros(numTests, 1);
elseif strcmp(metric, 'kld') || strcmp(metric, 'maxkld')
    testKLD = zeros(numTests, 2);
end
    

%% begin test on packet pairs
for iterTest = 1 : numTests
    [testSource, testSourceLength] = createTestSource(iterTest, pairIdx, source, packetlen);
    
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
        elseif strcmp(metric, 'maxkld')
            testKLD(iterTest, 1) = -1;
            testKLD(iterTest, 2) = -1;
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
        
    elseif strcmp(metric, 'kld') || strcmp(metric, 'maxkld')
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
elseif strcmp(metric, 'maxkld')
    meanKLD = mean(testKLD, 2);
    [mis, chosenPairsIdx] = sort(meanKLD, 'descend');
%      % compute a threshold which marks high KLD scores
%      [N, edges] = histcounts(testKLD(testKLD ~= -1));
%      for idxN = length(N) : -1 : 1
%          % make sure we have at least `numTests` packets
%          if sum( N( idxN: length(N))) > nPairs
%              kldThreshold = edges(idxN-1);
%              break;
%          end
%      end
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

% results for repeating overlaps algorithm
pctBytes_repeatingOverlaps = zeros(nPairs, 2, 2);
pctNibbles_repeatingOverlaps = zeros(nPairs, 2, 2);
pctBits_repeatingOverlaps = zeros(nPairs, 2, 2);
mse_repeatingOverlaps = zeros(nPairs, 2, 2);
scalingFactors_repeatingOverlaps = zeros(nPairs, 2);
ipv4checksum_repeatingOverlaps = zeros(nPairs, 2);

% results for mse minimization algorithm
pctBytes_mseMinimization = zeros(nPairs, 2, 2);
pctNibbles_mseMinimization = zeros(nPairs, 2, 2);
pctBits_mseMinimization = zeros(nPairs, 2, 2);
mse_mseMinimization = zeros(nPairs, 2, 2);
scalingFactors_mseMinimization = zeros(nPairs, 2);
ipv4checksum_mseMinimization = zeros(nPairs, 2);

% results for ip address overlaps algorithm
pctBytes_ipAddressOverlap = zeros(nPairs, 2, 2);
pctNibbles_ipAddressOverlap = zeros(nPairs, 2, 2);
pctBits_ipAddressOverlap = zeros(nPairs, 2, 2);
mse_ipAddressOverlap = zeros(nPairs, 2, 2);
scalingFactors_ipAddressOverlap = zeros(nPairs, 2);
ipv4checksum_ipAddressOverlap = zeros(nPairs, 2);

% results for packet padding overlaps algorithm
pctBytes_portNumberOverlap = zeros(nPairs, 2, 2);
pctNibbles_portNumberOverlap = zeros(nPairs, 2, 2);
pctBits_portNumberOverlap = zeros(nPairs, 2, 2);
mse_portNumberOverlap = zeros(nPairs, 2, 2);
scalingFactors_portNumberOverlap = zeros(nPairs, 2);
ipv4checksum_portNumberOverlap = zeros(nPairs, 2);

idxNzOffset = 0;
%% run separation on the N pairs with the lowest MI/KLD for separation
for pairIter = 1 : nPairs

    if excludeZeros && pairIter == 1
        % if we want to exclude MI/KLD which are equal to zero
        idxNzOffset = find(mis, 1, 'first');
        testIdx = chosenPairsIdx(pairIter + idxNzOffset);
%      elseif strcmp(metric, 'maxkld')
%          % make sure that both sources have high KLD's
%          testIdx = chosenPairsIdx(pairIter);
%          idxKldOffset = 0;
%          kld2 = testKLD(testIdx, 2);
%          % TODO: this step does not work efficiently
%          %       a better solution which maximizes the KLD from both sources is required
%          while kld2 < kldThreshold
%              idxKldOffset = idxKldOffset + 1;
%              testIdx = chosenPairsIdx(pairIter + idxKldOffset);
%              kld2 = testKLD(testIdx, 2);
%          end
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
    % cobICA separation
    %%%%%%%%%%%%%%%%%%%%
    if strcmp(icaAlgo, 'cobICA')
        % for compatibility with cobICA gf arithmetic
        observations = observations - 1;
        testMixingMatrix = testMixingMatrix - 1;
        testSource = testSource - 1;
        
        funcao_fitness = @(ab)fitness_sum_mlh(ab, observations, base, degree, field);  

         [W, bestCost, meanCost, ABfinal, fitfinal, Cfinal, rstfit] = ...
           cobicaEF(2, base, degree, field, pm, funcao_fitness);

        U = produtomatrizGF(W, testMixingMatrix, base, degree, field);
        Z = (U>-1); %null element in GF(q^m) 
        hits = sum(sum(Z,2)==1);

        disp(Z);
        fprintf('%d hits for cobICA\n\n',hits);

        fprintf('Mixing matrix:\n');
        disp(testMixingMatrix);

        fprintf('Separating matrix:\n');
        disp(W);

        % record the mse between the ica estimate and the test sources
        icaEstimate = produtomatrizGF(W, observations, base, degree, field);
    %%%%%%%%%%%%%%%%%%%%
    % AMERICA separation
    %%%%%%%%%%%%%%%%%%%%
    elseif strcmp(icaAlgo, 'AMERICA')
        
        %working parameters
        K= 2;                           %Number of sources

        if binICA
            % convert source to binary and perform AMERICA in gf(2)
            P = base;                           %Galois order
            T = testSourceLength(1) * 4;     %Observation length

            A(1, :) = source2bin(testMixingMatrix(1, :));
            A(2, :) = source2bin(testMixingMatrix(2, :));

            X(1, :) = source2bin(observations(1, :));
            X(2, :) = source2bin(observations(2, :));
        else
            P = 2^4;
            gf_exp = log2(P);
            T = testSourceLength(1);
            A = gf(testMixingMatrix, 4);
            X = gf(observations, 4);
        end

        PK=P^K;

        %Now prepare for separation

        %construct a "Lexicon": Lex(:,n) is the (n-1)-th
        %index vector: n-1=Lex(1,n)+P*Lex(2,n)+P^2*Lex(3,n)+
        %...+P^(K-1)*Lex(K,n)
        Lex=zeros(K,PK);
        if ~binICA
            Lex = gf(Lex, gf_exp);
        end
        
        nvec=[0:PK-1];
        
        for k=1:K-1
            Lex(k,:)=mod(nvec,P);
            nvec=floor(nvec/P);
        end
        
        Lex(K,:)=nvec;
        %construct an "index-vector translation" vector:
        r=P.^[0:K-1]; 

        %estimate the probabilities "tensor"
        %(the P^K tensor is stored in a 1xP^K vector PPx:
        %PPx(n) represents the probability of occurrence
        %of x, such that n=r*x;
        
        PPx=zeros(1,PK);
        
        if binICA
            ixt=r*X;
        else
            ixt = r * double(X.x);
        end

        for t=1:T
            PPx(ixt(t)+1)=PPx(ixt(t)+1)+1;
        end
        
        PPx=PPx/T;
        
        if binICA
            Ba=america(PPx, P, K, PK, Lex, r);
        else
            Ba = america_gf2n(PPx, P, K, PK, Lex, r, gf_exp);
        end

        if binICA
            Da=mod(Ba*A,P); % 
            Danz=(Da>0); % the non-zero elements of Da
        else
            Da = Ba * A;
            Danz = (Da.x > 0);
        end

        sca=sum(sum(Danz,2)==1);
        if sca==K
            disp('AMERICA: succeeded')
        else
            disp('AMERICA: failed')
        end

        if binICA
            clearvars icaEstimate binIcaEstimate
            binIcaEstimate = mod(Ba * X, P);
            icaEstimate(1, :) = bin2source(binIcaEstimate(1, :));
            icaEstimate(2, :) = bin2source(binIcaEstimate(2, :));
        else
            clearvars icaEstimate icaEstimateGf
            icaEstimateGf = Ba * X;
            icaEstimate = gf2mat(icaEstimateGf);
        end

        clearvars X A r
    end

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
%             case 1
%                 % Find the optimal scaling coefficients by maximizing the
%                 % overlap of signal segments containing neighboring
%                 % repetitions.
%                 [scalingFactors_repeatingOverlaps(pairIter, :), bestScore, scaledSourceEstimate]  = ...
%                  findScalingFactorByMaximizingSignalOverlap(...
%                     testSource, icaEstimate, base, degree, field, false, icaAlgo);
            case 1
                % ipv4 checksum
                [scalingFactors_repeatingOverlaps(pairIter,:), ...
                  scaledSourceEstimate] = ...
                findScalingFactorByChecksum(icaEstimate, base, degree, field, icaAlgo);
             case 2
                % mse minimization
                [scalingFactors_mseMinimization(pairIter, :), bestScore, scaledSourceEstimate] = ...
                 findMinMseScalingFactor(...
                    testSource, icaEstimate, base, degree, field, errorFunc, false, icaAlgo);
             case 3
                % ip address overlap
                [scalingFactors_ipAddressOverlap(pairIter, :), bestScore, scaledSourceEstimate] = ...
                 findScalingFactorByIpAddressMatching(...
                    ipAddresses, icaEstimate, base, degree, field, false, icaAlgo);
             case 4
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
                            0 12 8 0;...
                            %{
                            % html 
                            % <A HREF=
                            3 12 4 1 2 0 4 8 5 2 4 5 4 6 3 13; ...
                            % </A>
                            3 12 2 15 4 1 3 14; ...
                            % <img src=
                            3 12 6 9 6 13  67 2 0 7 3 7 2 6 3 3 13;...
                            %}
                            ];
                [scalingFactors_portNumberOverlap(pairIter, :), bestScore, scaledSourceEstimate] = ...
                 findScalingFactorByIpAddressMatching(...
                    portNumbers, icaEstimate, base, degree, field, false, icaAlgo);
         end % end switch

        if strcmp(icaAlgo, 'cobICA')
            observations = observations + 1;
            testMixingMatrix = testMixingMatrix + 1;
            testSource = testSource + 1;
            icaEstimate = icaEstimate + 1;
            scaledSourceEstimate = scaledSourceEstimate + 1;
        end


        % record the mse between the scaled source estimate and the test source
        for mseIcaEstIdx  = 1 : 2
            for mseSourceIdx = 1 : 2
                mse_algo(mseIcaEstIdx, mseSourceIdx) = ...
                 errorFunc(...
                    scaledSourceEstimate(mseIcaEstIdx, :), testSource(mseSourceIdx, :));
            end
        end

        % record the percentage of bytes correctly estimated by the scaled estimate
        for mseIcaEstIdx  = 1 : 2
            for mseSourceIdx = 1 : 2
                pctBytes(mseIcaEstIdx, mseSourceIdx) = ...
                 calculatePctBytesCorrect(...
                    scaledSourceEstimate(mseIcaEstIdx, :), testSource(mseSourceIdx, :));
            end
        end 

        % record the percentage of nibbles correctly estimated by the scaled estimate
        for mseIcaEstIdx  = 1 : 2
            for mseSourceIdx = 1 : 2
                pctNibbles(mseIcaEstIdx, mseSourceIdx) = ...
                 calculatePctNibblesCorrect(...
                    scaledSourceEstimate(mseIcaEstIdx, :), testSource(mseSourceIdx, :));
            end
        end

        % record the percentage of bits correctly estimated by the scaled estimate
        for mseIcaEstIdx  = 1 : 2
            for mseSourceIdx = 1 : 2
                pctBits(mseIcaEstIdx, mseSourceIdx) = ...
                 calculatePctBitsCorrect(...
                    scaledSourceEstimate(mseIcaEstIdx, :), testSource(mseSourceIdx, :));
            end
        end
        
        % record whether the scaled estimated packets have a correct IPv4 checksum
        for mseIcaEstIdx  = 1 : 2
            ipv4checksum(1, mseIcaEstIdx) = ...
                verifyIPv4Checksum(scaledSourceEstimate(mseIcaEstIdx, :));
        end

        if strcmp(icaAlgo, 'cobICA')
            observations = observations - 1;
            testMixingMatrix = testMixingMatrix - 1;
            testSource = testSource - 1;
            icaEstimate = icaEstimate - 1;
            scaledSourceEstimate = scaledSourceEstimate - 1;
        end

        % save the results of the scaling tests
        switch iterAlgo
            case 1
                mse_repeatingOverlaps(pairIter,:,:) = mse_algo;
                pctBytes_repeatingOverlaps(pairIter,:,:) = pctBytes;
                pctNibbles_repeatingOverlaps(pairIter, :,:) = pctNibbles;
                pctBits_repeatingOverlaps(pairIter,:,:) = pctBits;
                ipv4checksum_repeatingOverlaps(pairIter,:) = ipv4checksum;
            case 2
                mse_mseMinimization(pairIter,:,:) = mse_algo;
                pctBytes_mseMinimization(pairIter,:,:) = pctBytes;
                pctNibbles_mseMinimization(pairIter, :,:) = pctNibbles;
                pctBits_mseMinimization(pairIter,:,:) = pctBits;
                ipv4checksum_mseMinimization(pairIter,:) = ipv4checksum;
            case 3
                mse_ipAddressOverlap(pairIter,:,:) = mse_algo;
                pctBytes_ipAddressOverlap(pairIter,:,:) = pctBytes;
                pctNibbles_ipAddressOverlap(pairIter, :,:) = pctNibbles;
                pctBits_ipAddressOverlap(pairIter,:,:) = pctBits;
                ipv4checksum_ipAddressOverlap(pairIter,:) = ipv4checksum;
            case 4
                mse_portNumberOverlap(pairIter,:,:) = mse_algo;
                pctBytes_portNumberOverlap(pairIter,:,:) = pctBytes;
                pctNibbles_portNumberOverlap(pairIter, :,:) = pctNibbles;
                pctBits_portNumberOverlap(pairIter,:,:) = pctBits;
                ipv4checksum_portNumberOverlap(pairIter,:) = ipv4checksum;
        end % end switch

        clearvars scaledSourceEstimate pctBits pctNibbles pctBytes mse_algo;
    end % switch for scaling algos tests
    kldSources(:,3) = kldSources(:,1) + kldSources(:,2);
end % pairs testing


%% summarize the results for each scaling search algorithm
for iterAlgo = 1 : numAlgos
    switch iterAlgo
        case 1
            mse_algo = mse_repeatingOverlaps;
            pctBytes = pctBytes_repeatingOverlaps;
            pctNibbles = pctNibbles_repeatingOverlaps;
            pctBits = pctBits_repeatingOverlaps;
            scalingFactors = scalingFactors_repeatingOverlaps;
            ipv4checksum = ipv4checksum_repeatingOverlaps;
            figName = 'ipv4_checksum';
        case 2
            mse_algo = mse_mseMinimization;
            pctBytes = pctBytes_mseMinimization;
            pctNibbles = pctNibbles_mseMinimization;
            pctBits = pctBits_mseMinimization;
            scalingFactors = scalingFactors_mseMinimization;
            ipv4checksum = ipv4checksum_mseMinimization;
            figName = 'MSE_minimization';
        case 3
            mse_algo = mse_ipAddressOverlap;
            pctBytes = pctBytes_ipAddressOverlap;
            pctNibbles = pctNibbles_ipAddressOverlap;
            pctBits = pctBits_ipAddressOverlap;
            scalingFactors = scalingFactors_ipAddressOverlap;
            ipv4checksum = ipv4checksum_ipAddressOverlap;
            figName = 'IP_address_matching';
        case 4
            mse_algo = mse_portNumberOverlap;
            pctBytes = pctBytes_portNumberOverlap;
            pctNibbles = pctNibbles_portNumberOverlap;
            pctBits = pctBits_portNumberOverlap;
            scalingFactors = scalingFactors_portNumberOverlap;
            ipv4checksum = ipv4checksum_portNumberOverlap;
            figName = 'port_number_matching';
    end %end switch

    % TODO: include delta mse
    T = table(...
                    packetPairName,...
                    lengthPacket1,...
                    lengthPacket2,...
                    kldSources(:,1),...
                    kldSources(:,2),...
                    kldSources(:,3),...
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
