% find repeating elements record start and stop positions

function [startIdx, stopIdx, value] = findRepeats(signal)


[B, N, Ind] = RunLength(signal);
Ind         = [Ind, length(signal) + 1];
Multiple    = find(N > 1);
startIdx    = Ind(Multiple);
stopIdx     = Ind(Multiple + 1) - 1;
value       = signal(startIdx);