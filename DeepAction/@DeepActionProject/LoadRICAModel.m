function [RICAModel, path] = LoadRICAModel(self)

modelFolder = fullfile(self.ProjectPath, 'rica_models');
if ~isfolder(modelFolder)
    RICAModel = [];
    path = [];
    return
end

[files, ~] = GetValidFolderFiles(modelFolder, 'Extension', 'mat');
for i = 1:size(files,1)
    currFile = fullfile(files.folder{i}, files.name{i});
    currMdlInfo = load(currFile, 'Info');
    currMdlInfo = currMdlInfo.Info;
    
    streams = self.ConfigFile.GetParams('Streams');
    camNames = self.ConfigFile.GetParams('CameraNames');
    desiredDim = self.ConfigFile.GetParams('NumDimensions');
    
    tf = CheckModel(currMdlInfo, streams, camNames, desiredDim);
    
    if tf == true
        RICAModel = load(currFile, 'RICAModel');
        RICAModel = RICAModel.RICAModel;
        path = currFile;
        return
    end
end

RICAModel = [];
path = [];
end

function tf = CheckModel(mdlInfo, streams, camNames, desiredDim)
if ~isequal(mdlInfo.Streams, streams)
    tf = false;
    return
end

if ~isempty(mdlInfo.CameraNames) || ~isempty(camNames)
    if ~isequal(mdlInfo.CameraNames, camNames)
        tf = false;
        return
    end
end



if ~isequal(mdlInfo.NumDimensions, desiredDim)
    tf = false;
    return
end

tf = true;

end