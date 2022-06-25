function behaviors = GetBehaviors(self)
self = self.Load();
behaviors = categories(self.AnnotationTable.Label);
end