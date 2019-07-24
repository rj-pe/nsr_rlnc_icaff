% computes a overlap score which is a quantitative value of equivalency
% between two signals based on the number of overlapping sections of repeating
% values. A negative score indicates that there are more overlapping sections
% which match in length and index but not in the value, i.e. there is potential
% for scaling correction of the test signal.

function score = computeOverlap(sourceRepeats, testSignalRepeats)
lenSourceRepeats = size(sourceRepeats, 2);
lenTestRepeats = size(testSignalRepeats, 2);
% pad the shorter repeats matrix with NaN's to facilitate comparison
if lenSourceRepeats > lenTestRepeats
	testSignalRepeats(1, lenTestRepeats : lenSourceRepeats) = NaN;
elseif lenTestRepeats > lenSourceRepeats
	sourceRepeats(1, lenSourceRepeats : lenTestRepeats) = NaN;
end
% value, start and end are equivalent
fullOverlaps = all(sourceRepeats == testSignalRepeats);
% weigh the overlaps by the length of the repeating segment
fullOverlaps = testSignalRepeats(2, fullOverlaps) - testSignalRepeats(1, fullOverlaps);

% start and end are equivalent
% partialOverlap = all(sourceRepeats(1:2, :) == testSignalRepeats(1:2, :));

% repeating sequences which are complete matches add to the score
% repeating sequences which match in length but not in value subtract from score

% originally partial overlaps were subtracted from the score.I'm not sure that is
% in any way meaningful or useful.

score = sum(fullOverlaps);% - sum(partialOverlap);