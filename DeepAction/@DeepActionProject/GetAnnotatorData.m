function self = GetAnnotatorData(self)
% Set up data for manual annotation
self = self.CreateClipTable('IncludeFeatures', false);
self = self.LoadData('IncludeFeatures', false);
end