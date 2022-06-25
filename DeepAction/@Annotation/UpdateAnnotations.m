function UpdateAnnotations(self, updatedAnnotT)
self = Load(self);

updatedFrame = updatedAnnotT.Frame;
updatedType = updatedAnnotT.Type;
updatedLabel = updatedAnnotT.Label;

[~, loc] = ismember(updatedFrame, self.AnnotationTable.Frame);
self.AnnotationTable.Type(loc) = updatedType;
self.AnnotationTable.Label(loc) = updatedLabel;
self.Save()
end
