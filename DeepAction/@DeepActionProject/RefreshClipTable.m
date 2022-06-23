function self = RefreshClipTable(self)
clipTPath = fullfile(self.ProjectPath, 'annotations', 'ClipTable.mat');

if isfile(clipTPath)
    s = load(clipTPath, 'ClipTable');
    self.ClipTable = s.ClipTable;
end
end