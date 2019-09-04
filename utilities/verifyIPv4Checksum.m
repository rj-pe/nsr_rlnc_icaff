function status = verifyIPv4Checksum(varargin)

% returns true if the ipv4 header's checksum is valid

if nargin == 1

packet = varargin{1,1};
% extract the ipv4 header from the packet
% bytes 15 - 34
ipHeader = packet(29:68);

elseif nargin == 2
% only the header was passed in
ipHeader = varargin{1,1};
end

% verify the protocol is ipv4
if all(ipHeader(1:2) == [4 5])
    % add the bytes of the header
    packetSum = dec2hex(uint32(sum(ipHeader)), 2);
    % add the carry bits
    total = hex2dec(packetSum(1)) + hex2dec(packetSum(2));
    % return true if contents sum to zero
    status = (total == hex2dec('f'));
else
    % packet does not use ipv4 protocol
    status = false;
end
