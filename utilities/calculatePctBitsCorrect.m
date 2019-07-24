function percentage = calculatePctBitsCorrect(estimate, original)

packetLength = size(original, 2);
bitsPacketLength = packetLength * 4;

estimate = uint8(estimate);
original = uint8(original);

% decompose signals to bits
bits_estimate = strings(1);
bits_original = strings(1);

for idx = 1 : packetLength
	bits_estimate = strcat(bits_estimate, dec2bin(estimate(idx), 4));
	bits_original = strcat(bits_original, dec2bin(original(idx), 4));
end

bits_estimate = char(bits_estimate);
bits_original = char(bits_original);

percentage = round(100 * (sum(bits_estimate == bits_original) / bitsPacketLength));

end
