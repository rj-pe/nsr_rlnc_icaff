function [testSource, testSourceLength, testSourceIdx] = ...
  createTestSource(iterTest, pairIdx, source, packetlen)
% This function is deprecated, marked for removal in later release.

% store the packets being tested into an appropriate length container
% the shorter packet has zero padding appended to match longer packet length
testSourceIdx(1) = pairIdx( iterTest, 1);
testSourceIdx(2) = pairIdx( iterTest, 2);
lengthSource1 = packetlen( pairIdx( iterTest, 1));
lengthSource2 = packetlen( pairIdx( iterTest, 2));
source1 = source( pairIdx( iterTest, 1), :);
source2 = source( pairIdx( iterTest, 2), :);

if lengthSource1 > lengthSource2
    testSourceLength(1) = lengthSource1;
else
    testSourceLength(1) = lengthSource2;
end

testSourceLength(2) = lengthSource1;
testSourceLength(3) = lengthSource2;

testSource = zeros(2, testSourceLength(1));
testSource(1, :) = source1(1: testSourceLength(1));
testSource(2, :) = source2(1: testSourceLength(1));

end
