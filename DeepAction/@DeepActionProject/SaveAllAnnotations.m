function SaveAllAnnotations(self, allAnnotT)
for i = 1:size(allAnnotT)
    currAnnot = Annotation(self, allAnnotT.VideoName{i});
    currAnnot.OverwriteAnnotation(allAnnotT.Annotations{i})
end
end
