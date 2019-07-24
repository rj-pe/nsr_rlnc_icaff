function percentage = calculatePctBytesCorrect(estimate, original)

packetLength = size(original, 2);
compressedPacketLength = packetLength / 2;

% compress signals to bytes
str_estimate = strings(1, compressedPacketLength);
str_original = strings(1, compressedPacketLength);

strIdx = 1;
for idx = 1 : 2 : packetLength
	str_estimate(strIdx) = strcat(string(dec2hex(estimate(idx))), string(dec2hex(estimate(idx+1))));
	str_original(strIdx) = strcat(string(dec2hex(original(idx))), string(dec2hex(original(idx+1))));
	strIdx = strIdx + 1;
end

bytes_estimate = uint8(zeros(1, compressedPacketLength));
bytes_original = uint8(zeros(1, compressedPacketLength));

for idx = 1 : compressedPacketLength
	bytes_estimate(idx) = uint8(hex2dec(str_estimate(idx)));
	bytes_original(idx) = uint8(hex2dec(str_original(idx)));
end

percentage = round(100 * (sum(bytes_estimate == bytes_original) / compressedPacketLength));

end