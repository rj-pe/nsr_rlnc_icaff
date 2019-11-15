function [mse_algo, pctBytes, pctNibbles, pctBits, ipv4checksum] = ...
            evaluateSeparationResults(...
            scaledSourceEstimate, testSource, errorFunc)
% inputs:
%   the scaled estimate of a packet from source
%   the source packets
%   the error function used

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
