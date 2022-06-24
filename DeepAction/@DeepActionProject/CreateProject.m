function CreateProject(self)
%CREATEPROJECT Creates new DeepActionProject
%   CREATEPROJECT(SELF) creates project folder in SELF.PROJECTPATH and
%   config file (if already exists, asks user whether to overwrite)

if ~isfolder(self.ProjectPath)
    mkdir(self.ProjectPath)
else
    msg = sprintf('Project with path %s already exists!', self.ProjectPath);
    warning(msg);
end

configFilePath = fullfile(self.ProjectPath, 'config.txt');

if isfile(configFilePath)
    prompt = 'Configuration file already exists, do you want to overwrite it? (y/n) ';
    response = input(prompt, 's');
    if strcmpi(response, 'n') || strcmp(response, 'no')
        return
    elseif strcmpi(response, 'y') || strcmp(response, 'yes')
        delete(configFilePath)
    else
        fprintf('Invalid response! Returning...')
        return
    end
else
    self.ConfigFile.CreateConfigFile()
end

end
