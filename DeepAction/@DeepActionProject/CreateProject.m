function CreateProject(self)
% Create new DeepAction project
if ~isfolder(self.ProjectPath)
    mkdir(self.ProjectPath)
end

self.ConfigFile.CreateConfigFile()
end
