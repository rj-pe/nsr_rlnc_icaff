% test N packet pairs for their Kullback-Leibler Divergence

workspaceName = 'pairingTest.mat';
load(workspaceName);
addpath("/home/ratjuice/NSR_test_bed/correlation/InfoTheory");

% pick packet pairs from list of packets
numTests = 5000;
numSources  = 2;

pairIdx = randi([1, numPackets], numTests, 2);
testPairs = zeros(numTests, maxPacketLength, 2);
testPairs(:, :, 1) = source(pairIdx(:, 1), :);
testPairs(:, :, 2) = source(pairIdx(:, 2), :);

testKLD = zeros(numTests, 2);
testMi = zeros(numTests, 2);
base = 2;
degree = 4;
alphabetSize = base^degree;
alphabet = 0 : alphabetSize-1;
uniformProb = 1 / alphabetSize;
uniform = ones(1, alphabetSize) .* uniformProb;

% calculate Kullback-Leibler Divergence for each packet pairing
maxSizeDiff = 200;
minSizeDiff = 0;

for iterTest = 1 : numTests
	% fetch the packet pairing
	[testSource, testSourceLength, testSourceIdx] = ...
	 createTestSource(iterTest, pairIdx, source, packetlen);

	% filter out the packet pairing if it contains packets with uneven lengths 
    if (testSourceLength(1) > min(testSourceLength(:,2:3)) + maxSizeDiff) || ...
            (min(testSourceLength(:, 2:3)) + minSizeDiff > testSourceLength(1))
        continue;
    else

	% calculate pmf of each packet in pair
	pmfSource1 = fitPmf2Source(testSource(1,:), base, degree)';
	pmfSource2 = fitPmf2Source(testSource(2,:), base, degree)';

	% calculate the KLD between each packet and a uniform distribution
	testKLD(iterTest, 1) = kldiv(alphabet, pmfSource1, uniform);
	testKLD(iterTest, 2) = kldiv(alphabet, pmfSource2, uniform);

    end
end

hold on
plot(sort(testKLD(:,1) + testKLD(:,2)));
hold off