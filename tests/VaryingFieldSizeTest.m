% Test which varies field size from 4 to maxFieldSize.

% Load packet data.
% Note that the character array which is loaded here is used with pickPackets()
% in the experiment below.
load('28388.mat', 'packets6');

% Define the parameters for this experiment.
% How many packet combinations in the experiment?
numCombinations = 10;
% Should we reject packets which are extremely short in length?
minimumPacketLength = 50;
% How large a field should we test?
maxFieldSize = 8;
% Do not change.
base = 2;
% How many packets will be combined in a single run?
numPacketsPerCombination = 2;
% start experiment
for iFieldSize = 4 : maxFieldSize
  % Create a CodeBreakResult object to keep track of experiment results.
  experimentResults = CodeBreakResults( ...
                                        numCombinations, ...
                                        numPacketsPerCombination, ...
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
                                iFieldSize, ...
                                sourceName, ...
                                numPacketsPerCombination, ...
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
    % Record the result of this code breaking attempt.
    experimentResults.LogResult(iExp, combo)
  end % Experiments loop.
  % Save experimental results to an Excel file.
  experimentResults.SaveToFile();
end % Varying field size loop.
