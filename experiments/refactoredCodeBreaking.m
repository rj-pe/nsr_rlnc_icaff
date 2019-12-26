%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% test parameters  %%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% Specify the maximum packet length desired for this test.
% Any pcap packet longer than this length will be truncated to this length.
maxPacketLength = 100;

% Specify the number of packet pairings to network coding.
% TODO: rename numTests to better describe it's function.
numTests = 10000;
zerosThreshold = 0.8;

% Specify how many sources are being combined.
numSources = 2;

% Specify the separation test parameters.
nPairs = 1000;

% specify the number of scaling algorithms used
% algorithm 1 = findFactorByChecksum.m
% algorithm 2 = findMinMseScalingFactor.m
numAlgos = 2;

% sorts by mse of observations for blind testing
% sorts by mse of original sources otherwise
blindTest = true;

% define the metric used for choosing pairs to separate
%metric = 'kld';
metric = 'mi';

% define the way in which error is measured
% mean squared error
errorFunc = @immse;

% mean absolute error
%errorFunc = @mae;

% Separate only non-zero mi/kld values if true
excludeZeros = false;

% which ica algorithm to use for separation
icaAlgo =  'AMERICA';
binICA = false;

% Specify the finite field used in the experiment.
base = 2;
% Degree of the finite field used when encoding packet data.
degree = 4;
% Construct list of finite field elements
field = gftuple((-1:base^degree-2)', degree, base);


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% packet data processing %%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% A pool of source packets is created from text files.

% Create the source matrix from text files containing pcap packet data.
[r, source, packetlen, numPackets] = ...
    createPacketData(...
      maxPacketLength, ...
      'httpWithJpegs.txt', ...
      'sessionPackets.txt', ...
      'httpOver80211.txt');

% The result metrics which are desired are indicated.
% Containers for only those chosen metrics are created.



% The experiment proceeds by passing N combined packets from the pool,
%    (where N is the number of sources to combine),
% through the network and code breaking information flow.

% The results are logged as the combined packets pass through the flow.
