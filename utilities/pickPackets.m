function [packets, packetName] = ...
  pickPackets(packetPool, minimumPacketLength, nPackets)
  % Combines nPackets number of packets that are at least minimumPacketLength
  % long. Packets are chosen from packetPool.
  packets = cell(nPackets, 1);
  indexBound = size(packetPool, 1);
  for iPacket = 1 : nPackets
    randomInteger = randi([1 indexBound], 1);
    while(strlength(packetPool(randomInteger)) < minimumPacketLength)
      randomInteger = randi([1 indexBound], 1);
    end
    if iPacket > 1
      packetName = packetName + "*" + string(randomInteger);
    else
      packetName = string(randomInteger);
    end
    packets{iPacket, 1} = packetPool(randomInteger);
  end
end % function