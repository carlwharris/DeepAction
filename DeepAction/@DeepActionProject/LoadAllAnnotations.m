function allAnnotT = LoadAllAnnotations(self)
VideoName = self.GetVideoNames('annotations');

Annotations = {};
for i = 1:length(VideoName)
    currAnnot = Annotation(self, VideoName{i});
    includeAll = true;
    currAnnot = currAnnot.Load(includeAll);
    currAnnotT = currAnnot.AnnotationTable;

    
    Annotations = [Annotations; {currAnnotT}];
end

allAnnotT = table(VideoName, Annotations);
end