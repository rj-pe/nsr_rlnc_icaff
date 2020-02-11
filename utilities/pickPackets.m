function [packets, packetName] = ...
  pickPackets(packetPool, minimumPacketLength, nPackets)
  % Combines nPackets number of packets that are at least minimumPacketLength
  % long. Packets are chosen from packetPool. The packetName is constructed
  % by concatenating the indices (from the orignal pool) of the chosen packets.
  packets = cell(nPackets, 1);
  indexBound = size(packetPool, 1);
  for iPacket = 1 : nPackets
    randomInteger = randi([1 indexBound], 1);
    % ensure we have met the minimum packet length requirement
    while(strlength(packetPool(randomInteger)) < minimumPacketLength)
      randomInteger = randi([1 indexBound], 1);
    end
    % Create name string
    if iPacket > 1
      packetName = packetName + "*" + string(randomInteger);
    else
      packetName = string(randomInteger);
    end
    % Add packet to output
    packets{iPacket, 1} = packetPool(randomInteger);
  end
end % function
