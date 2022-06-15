function CreateLabeledVideos(self, varargin)

p = inputParser;
p.KeepUnmatched=true;
addOptional(p, 'PlaybackSpeed', 1);
addOptional(p, 'Scale', 1);
addOptional(p, 'FontSize', 18);
parse(p,varargin{:});

playbackSpeed = p.Results.PlaybackSpeed; 
scale = p.Results.Scale;
fontSize = p.Results.FontSize;

outFolder = fullfile(self.ProjectPath, 'results', 'labeled_videos');

if ~isfolder(outFolder)
    mkdir(outFolder)
end

clipT = self.ClipTable;

uniqueVideos = unique(clipT.Video);


verboseLvl = self.ConfigFile.GetParams('VerboseLevel');

if verboseLvl > 0
    fprintf('Creating %d labeled videos %d... ', length(uniqueVideos));
end

for i = 1:length(uniqueVideos)
    currVideoName = uniqueVideos{i};

    if verboseLvl > 0
        fprintf('Creating labeled video  for clip number %d... ', clipT.ClipNumber(i))
    end

    isCurrVideo = strcmp(currVideoName, clipT.Video);
    currAnnotT = vertcat(clipT(isCurrVideo, :).Annotations{:});


    if self.ConfigFile.GetParams('MultipleCameras') == true
        camName = self.ConfigFile.GetParams('PrimaryCamera');
        inVidFolder = fullfile(self.ProjectPath, 'videos', currVideoName, camName);
    else
        inVidFolder = fullfile(self.ProjectPath, 'videos', currVideoName);
    end
    inVidFile = GetValidFolderFiles(inVidFolder);
    
    [~, ~, ext] = fileparts(inVidFile.name);
    inVidFile(strcmp(ext, '.mat'),:) = [];

    path = fullfile(inVidFile.folder{1}, inVidFile.name{1});
    vidReader = FrameReader(path);

    outVidName = sprintf('video_%s_labeled.mp4', currVideoName);
    outVidPath = fullfile(outFolder, outVidName);
    vidWriter = FrameWriter(outVidPath, 'Quality', 100, 'FrameRate', vidReader.FrameRate);

   
    for j = 1:playbackSpeed:length(currAnnotT.Frame)
        %currFrame = read(vidReader, currAnnotT.Frame(j));
        [vidReader, currFrame, ~] = vidReader.ReadFrame(currAnnotT.Frame(j));

        I = imresize(currFrame, scale);

        if playbackSpeed == 1
            vidName = sprintf('%s', inVidFile.name{1});
        else
            vidName = sprintf('%s (%d%s speed)', inVidFile.name{1}, playbackSpeed, 'x');
        end

        I = insertText(I,[0, size(I, 1)], vidName,'AnchorPoint','LeftBottom', ...
            'BoxColor', 'white', 'FontSize', round(fontSize*0.75), 'BoxOpacity', 0.5);

        midX = size(I, 2)/2;
        currType = currAnnotT.Type(j);
        if currType ~= categorical({'UL'})
            isRev = currType ~= categorical({'C'});

            if isRev
                currBehav = [char(currAnnotT.Label(j)), ' (human)'];
                textColor = [0.8500, 0.3250, 0.0980] * 255;
                I = insertText(I,[midX, 0],currBehav,'AnchorPoint','CenterTop', ...
                'FontSize', fontSize, 'TextColor', textColor, 'BoxOpacity', 0);

                currBehav = [char(currAnnotT.Prediction(j)), ' (model)'];
                textColor = [0 0.4470 0.7410] * 255;
                I = insertText(I,[midX, 20],currBehav,'AnchorPoint','CenterTop', ...
                'FontSize', fontSize, 'TextColor', textColor, 'BoxOpacity', 0);
            else
                currBehav = [char(currAnnotT.Label(j)), ' (model)'];
                textColor = [0 0.4470 0.7410] * 255;
                I = insertText(I,[midX, 0],currBehav,'AnchorPoint','CenterTop', ...
                'FontSize', fontSize, 'TextColor', textColor, 'BoxOpacity', 0);
            end
        end

        if self.ConfigFile.GetParams('MultipleCameras') == true
            ts = seconds(currAnnotT.TimeStamp.(camName)(j));
        else
            ts = seconds(currAnnotT.TimeStamp.TimeStamp(j));
        end
        ts.Format = 'hh:mm:ss';
        I = insertText(I,[size(I, 2), size(I, 1)], char(ts),'AnchorPoint','RightBottom', ...
            'BoxColor', 'white', 'FontSize', round(fontSize*0.75), 'BoxOpacity', 0.5);

        vidWriter = vidWriter.WriteFrame(I);

        if verboseLvl > 1
            ProgressBar(j, length(currAnnotT.Frame), 'TotalUpdates', inf);
        end

        if j > 9000
            break
        end

    end

    vidWriter.Close();
    vidReader.Close();
end
end
