function self = LoadSavedClassifier(self, varargin)
parentFolder = fullfile(self.ProjectPath, 'classifiers');

if nargin == 1
    subfolders = GetValidSubFolders(parentFolder);
    version = subfolders.name{end};
else
    version = varargin{1};
end

srcFolder = fullfile(parentFolder, version);

if ~isfolder(srcFolder)
    fprintf('Network %s does not exist!\n', version)
    return
end

path = fullfile(srcFolder, 'Network.mat');
s = load(path, 'Network');

self.Network = s.Network;

if self.VerboseLevel > 0
    fprintf('Successfully loaded network %s\n', version)
end
end