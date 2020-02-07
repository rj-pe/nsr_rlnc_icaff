% test of CodeBreakResults class

% load packet data
load('28388.mat', 'packets6');

% How many packet combinations in the experiment?
numCombinations = 10;
minimumPacketLength = 50;
maxPacketsPerCombination = 10;
for iNumPacketsPerCombination = 1 : maxPacketsPerCombination  
  % Create a CodeBreakResult to keep track of experiment results
  experimentResults = CodeBreakResults( ...
                                        numCombinations, ...
                                        iNumPacketsPerCombination, ...
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
                                        iNumPacketsPerCombination ...
                                      );
  
    % Combine the packets.
    combo  = PacketCombination( ...
                                2, ...
                                4, ...
                                sourceName, ...
                                iNumPacketsPerCombination, ...
                                source ...
                              );
    combo.Combine();
    % Separate the packets.
    combo.Separate();
    % Find the scaling factor which produces a correct ipv4 checksum.
    combo.FindScalingFactors(@findScalingFactorByChecksum);
    combo.ComputeCodeBreakResults(@immse);
  
    % Record the result of this experiment.
    experimentResults.LogResult(iExp, combo);
  end % experiments loop
  % Save results to an Excel file.
  experimentResults.SaveToFile();
end % varying sources loop
