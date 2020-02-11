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
% TODO: tempPacketData has dynamic sizing in the for loop below, how to fix?
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
    iPad = mod(numel(binData), degree);
    if iPad > 0
      % Decide whether:
      % rem((degree - iPad) + size(binData,1), degree) == 0 or 
      % rem(iPad + size(binData,1), degree) == 0
      if rem((degree - iPad) + size(binData,1), degree) == 0
        iPad = degree - iPad
      end
      % Add zero padding at the tail of the source packet.
      paddedBinData = vertcat(binData, zeros(iPad, size(binData, 2)));
    else
      % No padding needed.
      paddedBinData = binData;
    end  
    % Each column represents a symbol (needed for reshape).
    paddedBinData = paddedBinData';
    % This operation shifts the cut-off for each symbol, such that each symbol
    % is described by N (= degree) bits. 
    paddedBinData = reshape(paddedBinData, degree, []);
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

% example for sanity checks:
% src     = [ 3 0 9 ]
% degree  = 5
% binData = de2bi(src)
% pad     = mod(numel(binData), degree)
% binData = vertcat(binData, zeros(pad, size(binData, 2)))
% binData = binData'
% binData = reshape(binData, degree, [])
% src     = bi2de(binData')'  
