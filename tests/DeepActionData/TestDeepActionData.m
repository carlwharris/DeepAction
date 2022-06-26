

projectName = 'project_2';

projectParent = '/Users/harriscaw/Documents/Behavior classification/Projects';
data = DeepActionData(fullfile(projectParent, projectName))

%%
data.GetFeatureIndices()
data.GetAnnotationIndices()
data = data.CreateClipTable()

%%
data = data.LoadData()