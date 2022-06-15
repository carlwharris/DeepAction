function CreateLabeledClips(self, varargin)
p = inputParser;
p.KeepUnmatched=true;
addOptional(p, 'PlaybackSpeed', 1);
addOptional(p, 'Scale', 1);
addOptional(p, 'FontSize', 16);
addOptional(p, 'ColorScheme', 'dark')
parse(p,varargin{:});

playbackSpeed = p.Results.PlaybackSpeed; 
scale = p.Results.Scale;
fontSize = p.Results.FontSize;


clipT = self.ClipTable;
nClips = size(clipT, 1);
randIdxs = randperm(nClips);
clipT = clipT(randIdxs, :);

outFolder = fullfile(self.ProjectPath, 'results', 'labeled_clips');

if ~isfolder(outFolder)
    mkdir(outFolder)
end

for i = 1:size(clipT, 1)
    currVideoName = clipT.Video{i};
    currAnnotT = clipT.Annotations{i};
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


    outVidName = sprintf('clip-%d_%s_labeled_%0.0f.mp4', clipT.ClipNumber(i), currVideoName, clipT.Accuracy(i)*100);
    outVidPath = fullfile(outFolder, outVidName);
    vidWriter = FrameWriter(outVidPath, 'Quality', 100, 'FrameRate', vidReader.FrameRate);
%     vidWriter.Quality = 85;
%     open(vidWriter)

    verboseLvl = self.ConfigFile.GetParams('VerboseLevel');

    if verboseLvl > 0
        fprintf('Creating video for clip number %d... ', clipT.ClipNumber(i))
    end

    for j = 1:playbackSpeed:length(currAnnotT.Frame)
        %currFrame = read(vidReader, currAnnotT.Frame(j));
        [vidReader, currFrame, ~] = vidReader.ReadFrame(currAnnotT.Frame(j));

        scale = 240/size(currFrame, 1);
        I = imresize(currFrame, scale);
        
%         vidName = sprintf('%s', inVidFile.name{1});
        vidName = sprintf('Clip %d', clipT.ClipNumber(i));
        I = insertText(I,[0, size(I, 1)], vidName,'AnchorPoint','LeftBottom', ...
            'BoxColor', 'white', 'FontSize', round(fontSize*0.7), 'BoxOpacity', 0.4);

        midX = size(I, 2)/2;
        currType = currAnnotT.Type(j);
        if currType ~= categorical({'UL'})
            isRev = currType ~= categorical({'C'});

            if isRev
                currBehav = [char(currAnnotT.Label(j)), ' (human)'];

                if strcmp(p.Results.ColorScheme, 'dark')
                    textColor = [14, 57, 93];
                else
                    textColor = [57, 161, 142];
                end
                I = insertText(I,[midX, -5],currBehav,'AnchorPoint','CenterTop', ...
                'FontSize', fontSize, 'TextColor', textColor, 'BoxOpacity', 0);

                currBehav = [char(currAnnotT.Prediction(j)), ' (model)'];


                if strcmp(p.Results.ColorScheme, 'dark')
                    textColor = [13, 73, 32];
                else
                    textColor = [250, 121, 47];
                end
                I = insertText(I,[midX, 10],currBehav,'AnchorPoint','CenterTop', ...
                'FontSize', fontSize, 'TextColor', textColor, 'BoxOpacity', 0);
            else


                currBehav = [char(currAnnotT.Label(j)), ' (model)'];
                textColor = [0 0.4470 0.7410] * 255;
                I = insertText(I,[midX, 0],currBehav,'AnchorPoint','CenterTop', ...
                'FontSize', fontSize, 'TextColor', textColor, 'BoxOpacity', 0.4);
            end
        end

        if self.ConfigFile.GetParams('MultipleCameras') == true
            ts = seconds(currAnnotT.TimeStamp.(camName)(j));
        else
            ts = seconds(currAnnotT.TimeStamp.TimeStamp(j));
        end
        ts.Format = 'hh:mm:ss';

        if playbackSpeed == 1
            txt = sprintf('%s', inVidFile.name{1});
        else
            txt = sprintf('%s (%d%s speed)', char(ts), playbackSpeed, 'x');
        end

        I = insertText(I,[size(I, 2), size(I, 1)], txt,'AnchorPoint','RightBottom', ...
            'BoxColor', 'white', 'FontSize', round(fontSize*0.7), 'BoxOpacity', 0.4);

        vidWriter = vidWriter.WriteFrame(I);

        if verboseLvl > 1
            ProgressBar(j, length(currAnnotT.Frame), 'TotalUpdates', inf);
        end
% 
%         if j > 30 * vidReader.FrameRate
%             break
%         end
    end

    vidWriter.Close();
    vidReader.Close();

    if i >= 75
        break
    end
end
end
