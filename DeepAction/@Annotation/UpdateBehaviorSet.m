function UpdateBehaviorSet(self, behaviorSet)
self = self.Load();
self.AnnotationTable.Label = addcats(self.AnnotationTable.Label, behaviorSet);
self.Save()
end