function Save(self)
% Save annotations table to file

AnnotationTable = self.AnnotationTable;

currFolder = fullfile(self.ProjectPath, 'annotations', self.VideoName);
if ~isfolder(currFolder)
    mkdir(currFolder)
end

save(self.FilePath, 'AnnotationTable');
end