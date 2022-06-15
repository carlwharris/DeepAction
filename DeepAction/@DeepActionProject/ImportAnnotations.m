function ImportAnnotations(self, importTable, varargin)
if nargin == 3
    overwrite = varargin{1};
else
    overwrite=false;
end

annotFolder = fullfile(self.ProjectPath, 'annotations');

for i = 1:size(importTable,1)
    currVideoName = importTable.VideoName{i};
    currAnnotFile = importTable.FilePath{i};
    
    annot = Annotation(self, currVideoName);
    annot.AddFileAnnotations(currAnnotFile, overwrite);
end

if self.ConfigFile.GetParams('VerboseLevel') > 0
    fprintf('Syncing annotation categories...')
end
self.SyncAnnotationCategories()

if self.ConfigFile.GetParams('VerboseLevel') > 0
    fprintf('complete\n')
end
