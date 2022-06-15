function self = LoadData(self, varargin)

p = inputParser;
addOptional(p, 'IncludeFeatures', true);
parse(p,varargin{:});

inclFeats = p.Results.IncludeFeatures;


verboseLvl = self.ConfigFile.GetParams('VerboseLevel');

if verboseLvl > 1
    fprintf('  Loading clip data... \n')
end

clipT = self.ClipTable;

if inclFeats
    if any(strcmp('Features', clipT.Properties.VariableNames))
        clipT = removevars(clipT, 'Features');
    end

    clipT = LoadFeatures(self, clipT);
end

if any(strcmp('Annotations', clipT.Properties.VariableNames))
    clipT = removevars(clipT, 'Annotations');
end

clipT = LoadAnnotations(self, clipT);

self.ClipTable = clipT;

end