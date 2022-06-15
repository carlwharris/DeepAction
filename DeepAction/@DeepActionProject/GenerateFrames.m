function GenerateFrames(self, varargin)
p = inputParser;
p.KeepUnmatched=true;
addOptional(p, 'parallelize', false);
parse(p,varargin{:});

vidNames = GetVideoNames(self, 'frames');
verboseLvl = self.ConfigFile.GetParams('VerboseLevel');

streams = self.ConfigFile.GetParams('Streams');
cams = self.ConfigFile.GetParams('CameraNames');

outerTic = tic;
for i = 1:length(streams)
    if p.Results.parallelize
        parfor j = 1:length(vidNames)
            innerTic = tic;
            feat = Feature(self, vidNames{j}, streams{i}, cams)
            feat.GenerateFrames(varargin{:});
            fprintf('Video %s, stream %s extracted in %0.1f sec.\n', streams{i}, vidNames{j}, toc(innerTic))
        end
    else
        for j = 1:length(vidNames)
            feat = Feature(self, vidNames{j}, streams{i}, cams);
   
            if verboseLvl > 1
                fprintf('Extracting frames: %s stream from video %s: ', streams{i}, vidNames{j})
            end
            feat.GenerateFrames()
            fprintf('\n')
        end
    end
end

fprintf('Frames generated in a total time of %0.0f sec.', toc(outerTic))