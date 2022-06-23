function SyncAnnotationCategories(self)
folders = GetValidSubFolders(fullfile(self.ProjectPath, 'annotations'));

behaviors = {};
for i = 1:size(folders,1)
    currVideo = folders.name{i};

    currAnnot = Annotation(self, currVideo);
    currBehaviors = currAnnot.GetBehaviors();

    behaviors = [behaviors; currBehaviors];
end
behaviors = unique(behaviors);

for i = 1:size(folders,1)
    currVideo = folders.name{i};
    currAnnot = Annotation(self, currVideo);
    currAnnot.UpdateBehaviorSet(behaviors)
end
end