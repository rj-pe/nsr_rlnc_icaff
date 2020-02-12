function [packetData, maximumPacketLength] = ... 
                      distributeSymbols(  ...
                                          source, ...
                                          numberOfPacketsCombined, ...
                                          degree)

% Note: For the purpose of our experiments decompression is not necessary
%       as we can simply compare the compressed estimate to the original
%       estimate. However, in order to obtain the original source signals
%       a decompression routine would be required. This decompression routine is
%       is not implemented, but as the compression is symmetrical, it's trivial.

% Figure out which packet has less bytes.
% Set that number of bytes as the combination's maximum packet length.
tempLength = zeros(numberOfPacketsCombined, 1);
for iSrc = 1 : numberOfPacketsCombined
  tempLength(iSrc) = strlength(source{iSrc});
end
maximumPacketLength = min(tempLength);

% Store the char array source data as doubles in this object.
packetData = zeros( ...
                        numberOfPacketsCombined, ...
                        maximumPacketLength ...
                      );
for iSrc = 1 : numberOfPacketsCombined % store source packets
  for jStr = 1 : maximumPacketLength
    packetData(iSrc, jStr) = hex2dec(source{iSrc}{1}(jStr));
  end % for jStr
end % for iSrc
numBits = maximumPacketLength * 4;
padBits = mod(numBits, degree) * 4;
tempPacketData = zeros(numberOfPacketsCombined, numBits + padBits);
newLength = zeros(numberOfPacketsCombined,1);
% compress the source packets by mapping hex digits to a larger alphabet
if degree > 4
  for iRow = 1 : numberOfPacketsCombined
    % Convert to binary (each row represents a character in packet).
    binData = de2bi(packetData(iRow,:));
    % Calculate the necessary padding.
    iPad = degree - rem(numel(binData), degree);
    % Transpose binary data, & reshape as a 1x vector (Makes padding easy).
    binVector = reshape(binData', numel(binData), 1);
    % Add zero padding at the tail of the source packet.
    binVector = [binVector', zeros(1, iPad)];
    % This operation shifts the cut-off for each symbol, such that each symbol
    % is described by N (= degree) bits. 
    paddedBinData = reshape(binVector, degree, []);
    % Transposing binary data necessary b/c bi2de does row-wise transformation
    % Transposing the decimal result necessary b/c packets are stored as rows.
    tempLength =  size(bi2de(paddedBinData')', 2);
    tempPacketData(iRow,1:tempLength) = bi2de(paddedBinData')';
    % Record the new (shorter length) of the packet.
    % Note this calculation could be done arithmetically if need be.
    newLength(iRow) = tempLength;
  end % compression loop
% Remove additional bytes if any exist.
% Find the longest packet in the bundle.
maximumPacketLength = max(newLength);
% Delete any columns longer than the maximum length.
packetData = [];
packetData = tempPacketData(:, 1:maximumPacketLength);

end % function

