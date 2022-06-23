function self = LaunchAnnotator(self)
self.BackupAnnotations()
Annotator(self)
%             clipTPath = fullfile(self.ProjectPath, 'annotations', 'AnnotatorClipTable.mat');
%             s = load(clipTPath, 'AnnotatorClipTable');
%             self.ClipTable = s.ClipTable;
end