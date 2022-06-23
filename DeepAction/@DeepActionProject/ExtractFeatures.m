function ExtractFeatures(self, varargin)
p = inputParser;
p.KeepUnmatched=true;
addOptional(p, 'parallelize', false);
parse(p,varargin{:});

vidNames = GetVideoNames(self, 'frames');
verboseLvl = self.ConfigFile.GetParams('VerboseLevel');

streams = self.ConfigFile.GetParams('Streams');
cams = self.ConfigFile.GetParams('CameraNames');

if p.Results.parallelize
    parStreams = repmat(streams', length(vidNames), 1);
    parVidNames = repmat(vidNames, length(streams), 1);

    parfor i = 1:length(parStreams)
        tic;
        feat = Feature(self, parVidNames{i}, parStreams{i}, cams);
        feat.ExtractFeatures(varargin{:})
        endTime = toc;
        fprintf('Video %s, stream %s extracted in %0.1f sec.\n', parStreams{i}, parVidNames{i}, endTime)
    end
else
    for i = 1:length(streams)
        for j = 1:length(vidNames)
            feat = Feature(self, vidNames{j}, streams{i}, cams);

            if verboseLvl > 0
                fprintf('Extracting %s stream from video %s: ', streams{i}, vidNames{j})
            end
            feat.ExtractFeatures()
        end
    end
end
end