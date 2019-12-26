% test of PacketCombination class

% load some test data
load('28388.mat', 'packets9')
index1 = randi([1 39], 1); index2 = randi([1 39], 1);
testSource = {packets9(index1); packets9(index2)};
packetComboName = string(index1) + "*" + string(index2);

% create an instance of the PacketCombination class
disp("Construct the PacketCombination object")
combo = PacketCombination(2, 4, packetComboName, 2, testSource);

disp('************************ packet data **********************************');
combo.PacketData(1,1:20)
combo.PacketData(2,1:20)

disp('Combine source packets in a finite field');
combo.Combine()

disp('******************* coding coefficients *******************************');
combo.CodingCoefficients

disp('Separation of combined packets using ICA');
combo.Separate()
disp('*********************** packet estimate *******************************');
combo.PacketEstimate(1, 1:20)
combo.PacketEstimate(2, 1:20)

disp('Finding scaling factor using checksum')
combo.FindScalingFactors(@findScalingFactorByChecksum)
disp('******************* found scaling factors *****************************');
combo.ScalingCoefficients()

% disp('Finding scaling factors using minimum MSE');
% combo.FindScalingFactors(@findMinMseScalingFactor)
% disp('****************** found scaling factors *****************************');
% combo.ScalingCoefficients()

disp('****************** scaled packet estimate *****************************');
combo.PacketEstimate(1, 1:20)
combo.PacketEstimate(2, 1:20)

disp('Compute code breaking results');
combo.ComputeCodeBreakResults(@immse)
disp('*********************** results ****************************************')
combo.Results()
