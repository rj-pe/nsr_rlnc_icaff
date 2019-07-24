function binSource = source2bin(hexSource)

packetLength = size(hexSource, 2);

hexSource = uint8(hexSource);

% decompose signals to bits
binSourceString = strings(1);

for idx = 1 : packetLength
	binSourceString = strcat(binSourceString, dec2bin(hexSource(idx), 4));
end

binSource = double(char(binSourceString) - 48);
end