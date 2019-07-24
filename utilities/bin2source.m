function hexSource = bin2source(binSource)

bitsPacketLength = size(binSource, 2);
packetLength =  bitsPacketLength / 4;

% decompose signals to bits
hexSource = zeros(1, packetLength);
srcIdx = 1;
for idx = 1 : 4 : bitsPacketLength
    binString = string(1);
    for binIdx = 1 : 3
        binString = strcat(binString, string(binSource(idx + binIdx - 1))); 
    end

	hexSource(srcIdx) = bin2dec(binString);
	srcIdx = srcIdx + 1;
end

end
