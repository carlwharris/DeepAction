function self = SplitClipData(self)
% varargin: trainClipT, validationClipT, testClipT

verboseLevl = self.VerboseLevel;

if verboseLevl > 0
    fprintf('Loading network data...\n')
end


if verboseLevl > 0
    fprintf('  - Splitting into train/validate/test splits\n')
end

isAnnot = self.ClipTable.Type == categorical({'I'}) | ...
           self.ClipTable.Type == categorical({'A'}) | ...
           self.ClipTable.Type == categorical({'R'});

[trn, val, test] = RandomlySelectClipIndices(self, self.ClipTable(isAnnot, :));

setStr = repmat({'UR'}, size(self.ClipTable, 1), 1);
Set = categorical(setStr, {'Train', 'Validate', 'Test', 'UR'});

if any(strcmp('Set', self.ClipTable.Properties.VariableNames))
    self.ClipTable = removevars(self.ClipTable, 'Set');
end

self.ClipTable = addvars(self.ClipTable, Set, 'NewVariableNames', 'Set');
self.ClipTable = DesignateSet(self.ClipTable, 'Train', trn);
self.ClipTable = DesignateSet(self.ClipTable, 'Validate', val);
self.ClipTable = DesignateSet(self.ClipTable, 'Test', test);

if self.ConfigFile.GetParams('VerboseLevel') > 0
    fprintf('Clip data split into sets:\n')

    prop = self.ConfigFile.GetParams('TrainProportion');
    fprintf('    Train: %d clips (%d%%)\n', length(trn), prop*100)

    prop = self.ConfigFile.GetParams('ValidationProportion');
    fprintf('    Validation: %d clips (%d%%)\n', length(val), prop*100)

    prop = self.ConfigFile.GetParams('TestProportion');
    fprintf('    Test: %d clips (%d%%)\n', length(test), prop*100)
end
end

function clipT = DesignateSet(clipT, set, clipNums)
for i = 1:length(clipNums)
    isCurrClipNum = clipT.ClipNumber == clipNums(i);
    clipT.Set(isCurrClipNum) = categorical({set});
end
end