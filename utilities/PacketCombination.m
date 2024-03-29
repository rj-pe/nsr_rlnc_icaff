classdef PacketCombination < handle
  % A PacketCombination object can be initialized using two or more packets.
  % Source packets can be combined, separated, and scaled using methods
  % provided by this class. The success of code breaking can be measured.
  % WARNING: create separate PacketCombination instances for each algorithm 
  % used in the experiment.
  properties
    PacketData
    PacketCombinationName
    CombinedData
    NumberOfPacketsCombined
    CodingCoefficients
    ScalingCoefficients
    ScalingAlgorithm
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
                                      numPacketsCombined, ...
                                      source ...
                                    )
      % user-defined values
      obj.PacketCombinationName = packetName;
      obj.NumberOfPacketsCombined = numPacketsCombined;
      % Create numberical arrays which represent packet data.
      % This method compresses packet data if the degree of the
      % field size is larger than four.
      [ ...
      obj.PacketData, ...
      obj.MaximumPacketLength ] = distributeSymbols( ...
                                    source, ...
                                    obj.NumberOfPacketsCombined, ...
                                    degree ...
                                    );
      obj.Base = base;
      obj.Degree = degree;       
      obj.Field = ...
                  gftuple(  ...
                            (-1:base^degree-2)', ...
                            degree, ...
                            base ...
                          );

      obj.Results = ...
        cell( ...
              obj.NumberOfPacketsCombined^2 + obj.NumberOfPacketsCombined, ...
              2 ...
            );
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
          false, ...
          obj.NumberOfPacketsCombined);
    end % function separate

    %%%%%%%%%%%%%%%%%%%%%%%%
    % find scaling factors %
    %%%%%%%%%%%%%%%%%%%%%%%%
    function FindScalingFactors(obj, scalingAlgorithm) %
      % Uses the scaling algorithm specified by the function handle parameter
      % to find the optimal scaling factors of an ICA estimate.
      obj.ScalingAlgorithm = scalingAlgorithm;
      if (strcmp(func2str(scalingAlgorithm), "findScalingFactorByChecksum"))
        [obj.ScalingCoefficients, obj.PacketEstimate] = ...
          scalingAlgorithm(...
            obj.PacketEstimate, ...
            obj.Base, ...
            obj.Degree, ...
            obj.Field, ...
            'AMERICA');
      elseif (strcmp(func2str(scalingAlgorithm), "findMinMseScalingFactor"))
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
        if strcmp(func2str(obj.ScalingAlgorithm), "findScalingFactorByChecksum")
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
        else
            % Mark entries as NaN, because ipv4 checksum is undef. for
            % gf(n~=16). When a decision is made regarding the checksum
            % calculation for such fields this exception should be
            % adjusted.
            for iIca = 1 : obj.NumberOfPacketsCombined
              obj.Results(resultRows, :) = {"ipv4" + string(iIca), nan};
              resultRows = resultRows + 1;
            end
        end
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
