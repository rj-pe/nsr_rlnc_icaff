classdef PacketCombination < handle
  % A PacketCombination object can be initialized using two or more packets.
  % Source packets can be combined, separated, and scaled using methods
  % provided by this class. The success of code breaking can be measured.
  properties
    PacketData
    PacketCombinationName
    CombinedData
    NumberOfPacketsCombined
    CodingCoefficients
    ScalingCoefficients
    PacketEstimate
    Results cell
  end % public properties
  properties (Access = private)
    Base
    Degree
    Field
    MaximumPacketLength
  end % private properties
  methods
    %%%%%%%%%%%%%%%
    % constructor %
    %%%%%%%%%%%%%%%
    function obj = PacketCombination( ...
                                    base, ...
                                    degree, ...
                                    packetName, ...
                                    maxPackLen, ...
                                    varargin...
                                    ) % source
      % user-defined values
      % TODO pass in only a single array of packets instead of multiple packets
      % TODO add numPacketsCombined as a function parameter
      obj.PacketCombinationName = packetName;
      %obj.NumberOfPacketsCombined = numPacketsCombined;

      obj.NumberOfPacketsCombined = nargin - 4;
      obj.PacketData = zeros(obj.NumberOfPacketsCombined, maxPackLen);
      source = varargin';
      for iSrc = 1 : obj.NumberOfPacketsCombined % store source packets
        for jStr = 1 : maxPackLen
          obj.PacketData(iSrc, jStr) = hex2dec(source{iSrc}{1}(jStr));
        end % for jStr
      end % for iSrc

      obj.Base = base;
      obj.Degree = degree;       
      obj.MaximumPacketLength = maxPackLen;

      obj.Field = ...
        gftuple( ...
          (-1:base^degree-2)', ...
          degree, ...
          base);

      obj.Results = ...
        cell( ...
          obj.NumberOfPacketsCombined^2 + obj.NumberOfPacketsCombined, ...
          2);
    end % constructor

    %%%%%%%%%%%
    % combine %
    %%%%%%%%%%%
    function Combine(obj)
      [obj.CombinedData, obj.CodingCoefficients] = ...
        networkCoding( ...
          obj.PacketData, ...
          obj.Base, ...
          obj.Degree);
    end % function combine

    %%%%%%%%%%%%
    % separate %
    %%%%%%%%%%%%
    function Separate(obj)
      obj.PacketEstimate = ...
        ica( ...
          obj.CombinedData,...
          obj.CodingCoefficients, ...
          obj.MaximumPacketLength, ...
          obj.Base, ...
          obj.Degree, ...
          false);
    end % function separate

    %%%%%%%%%%%%%%%%%%%%%%%%
    % find scaling factors %
    %%%%%%%%%%%%%%%%%%%%%%%%
    function FindScalingFactors(obj, scalingAlgorithm) %
      % Uses the scaling algorithm specified by the function handle parameter
      % to find the optimal scaling factors of an ICA estimate.
      if (strcmp(func2str(scalingAlgorithm), "findScalingFactorByChecksum"))
        [obj.ScalingCoefficients, obj.PacketEstimate] = ...
          scalingAlgorithm(...
            obj.PacketEstimate, ...
            obj.Base, ...
            obj.Degree, ...
            obj.Field, ...
            'AMERICA');
      elseif (strcmp(func2str(scalingAlgorithm), "findMinMseScalingFactor"))
        % TODO create separate properties for each algorithm
        [obj.ScalingCoefficients, ~, obj.PacketEstimate] = ...
          scalingAlgorithm( ...
            obj.PacketData, ...
            obj.PacketEstimate, ...
            obj.Base, ...
            obj.Degree, ...
            obj.Field, ...
            @immse, ...
            false, ...
            'AMERICA');
      end % if check function name
    end % function find scaling factors

    %%%%%%%%%%%%%%%%%%%
    % compute results %
    %%%%%%%%%%%%%%%%%%%
    function ComputeCodeBreakResults(obj, metric)
      % Calculates the rate of code breaking success. Available parameterized 
      % metrics: mean squared error, percentage of correctly decoded bytes.
      % IPv4 checksum is always calculated and recorded.
        resultRows = 1;
        % Calculate error between each scaled source estimate and test source.
        for iIca = 1 : obj.NumberOfPacketsCombined
          for iSrc = 1 : obj.NumberOfPacketsCombined
            obj.Results(resultRows, :) = ...                %   Result -> Cell.
            { ...
            "src" + string(iSrc) + "est" + string(iIca), ... %      Column Name.
            metric( ...                                      %   Error function.
              obj.PacketEstimate(iIca, :), ...
              obj.PacketData(iSrc, :)) ...
            };
            resultRows = resultRows + 1;
          end % end inner loop for error function parameter
        end % end outer loop for error function parameter

        % Calculate the IPv4 checksum of each scaled source estimate
        for iIca = 1 : obj.NumberOfPacketsCombined
          obj.Results(resultRows, :) = ...                   %   Result -> Cell.
          { ...
          "ipv4" + string(iIca), ...                         %      Column Name.
          verifyIPv4Checksum( ...                            %   Error function.
            obj.PacketEstimate(iIca, :))
          };
          resultRows = resultRows + 1;
        end % IPv4 checksum calculation
    end % function compute results
  end % methods

  methods (Access = private)
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    % method signatures for functions defined in other files %
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    [packetCombined, mixingMatrix] = networkCoding( sources, base, degree)
    [icaEstimate] = ica(  observations, ...
                          testMixingMatrix, ...
                          testSourceLength, ...
                          base, ...
                          degree, ...
                          binICA)
    status = verifyIPv4Checksum(varargin)
  end % private methds
end % classdef