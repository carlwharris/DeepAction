function InitializeAnnotations(self)

if self.VerboseLevel > 0
    fprintf('  Initializing annotations:  ')
end

vidNames = GetVideoNames(self, 'videos');

for i = 1:length(vidNames)
    annot = Annotation(self, vidNames{i});
    annot.InitializeAnnotation()

    if self.VerboseLevel > 0
        ProgressBar(i, length(vidNames))
    end
end

end