function self = GetClassifierData(self)
if self.VerboseLevel > 0
    fprintf('Creating clips and loading clip data to train the classifier...\n')
end

self = self.CreateClipTable('IncludeFeatures', true);
self = self.LoadData('IncludeFeatures', true);
end