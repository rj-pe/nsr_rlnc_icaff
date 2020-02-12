% Test which varies field size from 4 to maxFieldSize.
% Results 2/12/2020: Any field size supported by gf() is processed by this
% test configuration. However, the ipv4 checksum computation only works on
% packets mapped to gf(2^4). One possible solution is to compute the
% checksum in binary.

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
for iFieldSize = 7 : maxFieldSize
  % Create a CodeBreakResult object to keep track of experiment results.
  experimentResults = CodeBreakResults( ...
                                        numCombinations, ...
                                        numPacketsPerCombination, ...
                                        "min_mse" ...
                                      );
  % Each iteration combines & subsequently separates packets.
  % The result of each code breaking attempt is logged to the 
  % experimentResults object.
  for iExp = 1 : numCombinations
    % Create a test signal by choosing packets at random from a pool of packets.
    [source, sourceName] = pickPackets( ...
                                        packets6, ...
                                        minimumPacketLength, ...
                                        numPacketsPerCombination ...
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
    % Find the scaling factor which minimizes the mean squared error from source.
    combo.FindScalingFactors(@findMinMseScalingFactor);
    % Compare the code breaking estimate to the original packet content.
    combo.ComputeCodeBreakResults(@immse);
    % Record the result of this code breaking attempt.
    experimentResults.LogResult(iExp, combo)
  end % Experiments loop.
  % Save experimental results to an Excel file.
  experimentResults.SaveToFile();
end % Varying field size loop.
