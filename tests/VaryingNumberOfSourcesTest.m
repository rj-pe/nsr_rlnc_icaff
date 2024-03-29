% test of CodeBreakResults class

% load packet data
load('28388.mat', 'packets6');

% experimental parameters
% How many packet combinations in the experiment?
numCombinations = 4;
minimumPacketLength = 50;
maxPacketsPerCombination = 10;
base = 2;
degree = 4;
% start experiment
for iNumPacketsPerCombination = 2 : maxPacketsPerCombination  
  % Create a CodeBreakResult object to keep track of experiment results.
  experimentResults = CodeBreakResults( ...
                                        numCombinations, ...
                                        iNumPacketsPerCombination, ...
                                        "checksum" ...
                                      );
  % Each iteration combines & subsequently separates packets.
  % The result of each code breaking attempt is logged to the 
  % experimentResults object.
  for iExp = 1 : numCombinations
    % Create a test signal by choosing packets at random from a pool of packets.
    [source, sourceName] = pickPackets( ...
                                        packets6, ...
                                        minimumPacketLength, ...
                                        iNumPacketsPerCombination ...
                                      );
    % Create the packet combination object.
    combo  = PacketCombination( ...
                                base, ...
                                degree, ...
                                sourceName, ...
                                iNumPacketsPerCombination, ...
                                source ...
                              );
    % Combine the packets using network coding.
    combo.Combine();
    % Separate the packets.
    combo.Separate();
    % Find the scaling factor which produces a correct ipv4 checksum.
    combo.FindScalingFactors(@findScalingFactorByChecksum);
    % Compare the code breaking estimate to the original packet content.
    combo.ComputeCodeBreakResults(@immse);
    % Record the result of this experiment.
    experimentResults.LogResult(iExp, combo)
  end % experiments loop
  % Save results to an Excel file.
  experimentResults.SaveToFile();
end % varying sources loop
