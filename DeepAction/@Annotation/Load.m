function self = Load(self, varargin)
% Load annotation table from file

if nargin == 2
    includeAll = true;
else
    includeAll = false;
end

if ~isfile(self.FilePath)
    return
end

s = load(self.FilePath, 'AnnotationTable');
self.AnnotationTable = s.AnnotationTable;

if self.MultiCam && ~includeAll
    ts = self.AnnotationTable.TimeStamp;
    notNan = ~isnan(ts.(self.PrimaryCamera));
    self.AnnotationTable = self.AnnotationTable(notNan, :);
end
end