function ImportVideos(self, importTable, varargin)
% Import videos contained in 'importTable' into project
% 
% importTable   - table with data to input
%   First column - name corresponding to video in row
%   Second column - path to video

videosFolder = fullfile(self.ProjectPath, 'videos');

verboseLvl = self.ConfigFile.GetParams('VerboseLevel');

if verboseLvl > 0
    fprintf('Importing %d videos to project %s\n', size(importTable, 1), self.ProjectName)
end


if verboseLvl > 0
    fprintf('  Copying files:  ')
end

for iRow = 1:size(importTable,1)
    currVideoName = importTable{iRow, 1}{1};

    if size(importTable, 2) > 2
        multicam = true;
    else
        multicam = false;
    end

    if multicam
        varNames = importTable.Properties.VariableNames; 
        camNames = sort(varNames(2:end));
        self.ConfigFile.EditFile('MultipleCameras', 'true')

        formattedCamNames = ['[', strjoin(camNames, ','), ']'];
        self.ConfigFile.EditFile('CameraName', formattedCamNames)
        self.ConfigFile.EditFile('PrimaryCamera', ['''', camNames{1}, ''''])

        for j = 1:length(camNames)
            currCam = camNames{j};
            currFilePath = importTable{iRow, j+1}{1};
            [~, fileName, ext] = fileparts(currFilePath);
            fileName = [fileName ext];

            destFolder = fullfile(videosFolder, currVideoName, currCam);
    
            if ~exist(destFolder, 'dir')
                mkdir(destFolder)
            end

            destPath = fullfile(destFolder, fileName);
        
            copyfile(currFilePath, destPath, 'f')
        
        end

    else
        [~, fileName, ext] = fileparts(importTable{iRow, 2}{1});
        fileName = [fileName ext];
    
        destFolder = fullfile(videosFolder, currVideoName);
    
        if ~exist(destFolder, 'dir')
            mkdir(destFolder)
        end
    
        destPath = fullfile(destFolder, fileName);
        
        copyfile(importTable{iRow, 2}{1}, destPath, 'f')
    
        if verboseLvl > 0
            fprintf('complete\n')
        end
    end

    if verboseLvl > 0
        ProgressBar(iRow, size(importTable,1))
    end
end

self.InitializeAnnotations()

end