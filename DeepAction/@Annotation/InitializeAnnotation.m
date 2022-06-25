function InitializeAnnotation(self)
if isfile(self.FilePath)
    return
end

if self.MultiCam
    videoFolderPath = fullfile(self.ProjectPath, 'videos', self.VideoName, self.CameraNames{1});

    file = GetValidFolderFiles(videoFolderPath);

    [~, ~, ext] = fileparts(file.name);
    file(strcmp(ext, '.mat'),:) = [];
    videoPath = fullfile(file.folder{1}, file.name{1});

    fr = FrameReader(videoPath);

    if strcmp(fr.ImageType, 'sequence')
        timeStamps = fr.SeqTS;
    else
        timeStamps = [];
        while HasFrame(fr)
            [fr, ~, ts] = fr.ReadFrame();
            timeStamps = [timeStamps; ts];
        end
    end
    fr.Close();
    
    for i = 2:length(self.CameraNames)
        videoFolderPath = fullfile(self.ProjectPath, 'videos', self.VideoName, self.CameraNames{i});

        file = GetValidFolderFiles(videoFolderPath);

        [~, ~, ext] = fileparts(file.name);
        file(strcmp(ext, '.mat'),:) = [];
        videoPath = fullfile(file.folder{1}, file.name{1});
%         
        fr = FrameReader(videoPath);

        if strcmp(fr.ImageType, 'sequence')
            currCamTimeStamps = fr.SeqTS;
        else
            currCamTimeStamps = [];
            while HasFrame(fr)
                [fr, ~, ts] = fr.ReadFrame();
                currCamTimeStamps = [currCamTimeStamps; ts];
            end
        end
        fr.Close()

        if size(timeStamps, 1) > size(currCamTimeStamps,1)
            diff = size(timeStamps, 1) - size(currCamTimeStamps,1);
            tmp = nan(diff, 1);
            currCamTimeStamps = [currCamTimeStamps; tmp];
        end

        if size(timeStamps, 1) < size(currCamTimeStamps,1)
            diff = size(currCamTimeStamps,1) - size(timeStamps, 1);
            tmp = nan(diff, size(timeStamps, 2));
            timeStamps = [timeStamps; tmp];
        end

        timeStamps = [timeStamps currCamTimeStamps];
    end

    timeStamps = array2table(timeStamps, 'VariableNames',self.CameraNames);
else
    videoFolderPath = fullfile(self.ProjectPath, 'videos', self.VideoName);

    file = GetValidFolderFiles(videoFolderPath);

    [~, ~, ext] = fileparts(file.name);
    file(strcmp(ext, '.mat'),:) = [];
    videoPath = fullfile(file.folder{1}, file.name{1});

    fr = FrameReader(videoPath);
    timeStamps = [];
    while HasFrame(fr)
        [fr, ~, ts] = fr.ReadFrame();
        timeStamps = [timeStamps; ts];
    end
    fr.Close();

    timeStamps = table(timeStamps, 'VariableNames', {'TimeStamp'});
end

% Types
% I - imported
% A - annotated
% C - classifier labels
% R - reviewed
% UL - unlabeled
typeStr = repmat({'UL'}, size(timeStamps, 1), 1);
types = categorical(typeStr, {'I', 'A','R', 'C', 'UL'});
frameIdxs = [1:size(timeStamps,1)]';

labelsStr = repmat({'UL'}, size(timeStamps,1), 1);
labels = categorical(labelsStr, {'UL'});
emptyT = table(frameIdxs, timeStamps, types, labels, ...
'VariableNames', ...
{'Frame', 'TimeStamp', 'Type', 'Label'});

self.AnnotationTable = emptyT;
self.Save()


end