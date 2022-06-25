function [annotIdxs, unannotIdx] = GetAnnotationIndices(self)
self = self.Load();

if isempty(self.AnnotationTable)
    annotIdxs = [];
    unannotIdx = [];
    return
end

isAnnot = self.AnnotationTable.Type == categorical({'I'}) | ...
          self.AnnotationTable.Type == categorical({'A'}) | ...
          self.AnnotationTable.Type == categorical({'R'});
annotIdxs = self.AnnotationTable.Frame(isAnnot);
unannotIdx = self.AnnotationTable.Frame(~isAnnot);
end