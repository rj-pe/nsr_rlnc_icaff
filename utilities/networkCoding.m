function [encodedPackets, randomCoefficients] = networkCoding(receivedPackets, base, degree)
% Description: Cascaded network coding using gf matrix multiplication.

numPackets = size(receivedPackets, 1);
alphabetSize = base^ degree;

receivedPacketsGf = gf(receivedPackets, degree);

% generate matrix of random coefficients
% coefficients are integer values drawn from the uniform discrete distribution
% on 0 to 2^n -1 inclusive
rng('shuffle');
randomCoefficients = randi([0  (alphabetSize - 1)], numPackets);
randomCoefficientsGf = gf(randomCoefficients, degree);

invertible = false;

while ~invertible
	try 
		inv(randomCoefficientsGf);
		% random coefficients are invertible proceed with NC
		invertible = true; 
	catch
		% previously generated random coefficients 
		% were not invertible generate another batch
		rng('shuffle');
		randomCoefficients = randi([0  (alphabetSize - 1)], numPackets);
		randomCoefficientsGf = gf(randomCoefficients, degree);	
	end
end

% matrix multiplication in gf
encodedPacketsGf = randomCoefficientsGf * receivedPacketsGf;

% each row is an encoded packet sent from an intermediate node
% at the first layer of a cascaded network topology.
encodedPackets = gf2mat(encodedPacketsGf);
