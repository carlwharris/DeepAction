function GenerateFrames(self, varargin)
%GENERATEFRAMES Generates spatial/temporal frames
%   GENERATEFRAMES(SELF) generates frames for streams and cameras specified
%   in the config file
%
%   GENERATEFRAMES(..., 'PARALLELIZE', TRUE) parallelizes the process (by
%   default, no parallelization is used) 

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

            if verboseLvl > 1
                fprintf('Stream %s, video %s extracted in %0.1f sec.\n', streams{i}, vidNames{j}, toc(innerTic))
            end
        end
    else
        for j = 1:length(vidNames)
            feat = Feature(self, vidNames{j}, streams{i}, cams);
   
            if verboseLvl > 1
                fprintf('Extracting stream %s frames from video %s: ', streams{i}, vidNames{j})
            end
            feat.GenerateFrames()

            if verboseLvl > 1
                fprintf('\n')
            end
        end
    end

    if verboseLvl > 0
        fprintf('%s stream frames generated in %0.0f sec.\n', streams{i}, toc(outerTic))
    end
end

end