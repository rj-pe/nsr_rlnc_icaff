classdef CodeBreakResults < handle
  % A CodeBreakResult object logs information from the results
  % of code breaking attempt to a file.
  properties (Access = private)
    ScalingAlgorithmName
  end % private properties
  properties
    ResultsTable
    ExperimentName
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
      obj.ExperimentName = strcat(datestr(now), "-", obj.ScalingAlgorithmName);
      obj.ResultsTable = createTable(numPacketsPerCombination, numCombinations);
    end % constructor

    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    % Log code breaking result %
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    function LogResult(obj, index, PacketCombinationObj)
      % create row from packet combination
      addRow = cell(1, size(obj.ResultsTable, 2));
      addRow{1} = PacketCombinationObj.PacketCombinationName;
      addRow = [addRow(1), PacketCombinationObj.Results(:,2)'];
      % add row to table
      obj.ResultsTable(index, :) = addRow;
    end % LogResult

    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    % Save results table to file %
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    function SaveToFile(obj)
      filename = strcat(obj.ExperimentName, ".xlsx");
      writetable(obj.ResultsTable, filename);
      disp(filename + " saved");
    end
  end % methods

  %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
  % method signatures for functions defined in other files %
  %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%  
  methods (Access = private)
    table = createTable(ppCombo, numCombinations)
  end % private methods

end % class
