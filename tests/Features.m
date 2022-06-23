

%%
projectFolder = '/Users/harriscaw/Documents/Behavior classification/Projects/JuangSetup';
project = DeepActionProject(projectFolder);

%%
% feat = Feature(project, '20080324115556', 'spatial', [])
% feat = Feature(project, '20080324115556', 'temporal', [])

feat = Feature(project, '20080324115556', 'spatial', [])
indices = feat.GetFeatureIndices()