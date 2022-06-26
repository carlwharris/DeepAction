function status = GetAnnotationIndices(self)
videoNames = GetVideoNames(self);

Video = {};
AnnotatedIndices = {};
UnannotatedIndices = {};

if self.VerboseLevel > 0
    fprintf('    Collecting annotation status for %d videos...', length(videoNames))
end

for i = 1:length(videoNames)
    currVideoName = videoNames{i};
    
    currAnnot = Annotation(self, currVideoName);
    [isAnnotIdx, isNotAnnotIdx] = GetAnnotationIndices(currAnnot);
    
    Video = [Video; currVideoName];
    AnnotatedIndices = [AnnotatedIndices; {isAnnotIdx}];
    UnannotatedIndices = [UnannotatedIndices; {isNotAnnotIdx}];
end

status = table(Video, AnnotatedIndices, UnannotatedIndices);

if self.VerboseLevel > 0
    fprintf('complete\n')
end

end