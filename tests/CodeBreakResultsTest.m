% test of CodeBreakResults class

% load packet data
load('28388.mat', 'packets6');

% How many packet combinations in the experiment?
numCombinations = 10;
minimumPacketLength = 50;
numPacketsPerCombination = 2;
% Create a CodeBreakResult to keep track of experiment results
experimentResults = CodeBreakResults( ...
                                      numCombinations, ...
                                      numPacketsPerCombination, ...
                                      "checksum" ...
                                    );
% Each iteration combines then separates packets.
%  The result of each code breaking attempt is logged to the 
%  experimentResults object.
for iExp = 1 : numCombinations
  % create a test signal by choosing packets at random from a pool.
  [source, sourceName] = pickPackets( ...
                                      packets6, ...
                                      minimumPacketLength, ...
                                      numPacketsPerCombination ...
                                    );
  % TODO: consider whether the PacketCombination constructor should perform
  %       the computaion to find the shortest packet lenth.
  shortestSourceLength = min(strlength(convertCharsToStrings(source)));
  % Combine the packets.
  combo  = PacketCombination( ...
                              2, 4, ...
                              sourceName, ...
                              shortestSourceLength, ...
                              source{1}, ...
                              source{2} ...
                            );
  combo.Combine();
  combo.Separate();
  combo.FindScalingFactors(@findScalingFactorByChecksum);
  combo.ComputeCodeBreakingResults(@immse);
  
  % Record the result of this experiment.
  experimentResults.SaveResult(combo);
end % experiments loop

% Record all results to an Excel file.
experimentResults.SaveToFile();
