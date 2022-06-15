function videoNames = GetVideoNames(self, varargin)
inclVideo = true;
inclFrames = true;
inclFeats = true;
inclAnnots = true;

if nargin == 2
    if strcmpi(varargin{1}, 'videos')
        inclFrames = false;
        inclFeats = false;
        inclAnnots = false;
    end

    if strcmpi(varargin{1}, 'frames')
        inclVideo = false;
        inclFeats = false;
        inclAnnots = false;
    end

    if strcmpi(varargin{1}, 'features')
        inclVideo = false;
        inclFrames = false;
        inclAnnots = false;
    end

    if strcmpi(varargin{1}, 'annotations')
        inclVideo = false;
        inclFrames = false;
        inclFeats = false;
    end    
end

videoNames = {};

if inclVideo == true
    currFolderPath = fullfile(self.ProjectPath, 'videos');
    if isfolder(currFolderPath)
        currFolders = GetValidSubFolders(currFolderPath);
        videoNames = [videoNames; currFolders.name];
    end
end

currFolderPath = fullfile(self.ProjectPath, 'annotations');
if isfolder(currFolderPath)
    currFolders = GetValidSubFolders(currFolderPath);
    videoNames = [videoNames; currFolders.name];
end

streams = self.ConfigFile.GetParams('Streams');

if inclFrames == true
    currParentFolderPath = fullfile(self.ProjectPath, 'frames');
    for i = 1:length(streams)
        currFolderPath = fullfile(currParentFolderPath, streams{i});

        if isfolder(currFolderPath)
            currFolders = GetValidSubFolders(currFolderPath);
            videoNames = [videoNames; currFolders.name];
        end
    end
end

if inclFeats == true
    currParentFolderPath = fullfile(self.ProjectPath, 'features');            
    for i = 1:length(streams)
        currFolderPath = fullfile(currParentFolderPath, streams{i});

        if isfolder(currFolderPath)
            currFolders = GetValidSubFolders(currFolderPath);
            videoNames = [videoNames; currFolders.name];
        end
    end
end

if inclAnnots == true
    currFolderPath = fullfile(self.ProjectPath, 'annotations');
    if isfolder(currFolderPath)
        currFolders = GetValidSubFolders(currFolderPath);
        videoNames = [videoNames; currFolders.name];
    end
end



videoNames = unique(videoNames);
end
