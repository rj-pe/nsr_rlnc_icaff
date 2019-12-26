classdef CodeBreakResults < handle
  % A CodeBreakResult object logs information from the results
  % of code breaking attempt to a file.
  properties (Access = private)
    ScalingAlgorithmName
  end % private properties
  properties
    ResultsTable
  end % public properties
  methods
  
    %%%%%%%%%%%%%%%
    % constructor %
    %%%%%%%%%%%%%%%
    function obj = CodeBreakResults( ...
                                      numCombinations, ...
                                      numPacketsPerCombination, ...
                                      algoName ...
                                    )
      obj.ScalingAlgorithmName = algoName;
      obj.ResultsTable = createTable(numPacketsPerCombination, numCombinations);
    end % constructor

    % TODO SaveToFile method
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    % Save code breaking result %
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    function SaveResult(obj, PacketCombinationObj)
      % create row from packet combination
      addRow = { ...
        PacketCombinationObj.PacketName, ... 
        reshape(... % TODO extract only data not names
          permute(PacketCombinationObj.Results, 2, 1), ...
          1, []), ...
        };
      % add row to table
      obj.ResultsTable = ...
        [obj.ResultsTable; addRow];
    end % RecordResult

  end % methods

  %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
  % method signatures for functions defined in other files %
  %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%  
  methods (Access = private)
    table = createTable(ppCombo, numCombinations)
  end % private methods

end % class


