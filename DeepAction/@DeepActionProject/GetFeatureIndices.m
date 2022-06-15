
function status = GetFeatureIndices(self)
streams = self.ConfigFile.GetParams('Streams');
cams = self.ConfigFile.GetParams('CameraNames');


videoNames = GetVideoNames(self);

if self.VerboseLevel > 0
    fprintf('  Collecting feature status for %d videos  ', length(videoNames))
end

Video = {};
FeatureIndices = {};
for i = 1:length(videoNames)
    currVideoName = videoNames{i};

    currFeatureIndices = [];
    
    for j = 1:length(streams)
        if self.ConfigFile.GetParams('MultipleCameras') == true
            camNames = self.ConfigFile.GetParams('CameraNames');
            for k = 1:length(camNames)
                currFeat = Feature(self, currVideoName, streams{j}, camNames{k});
                currIndices = currFeat.GetFeatureIndices();

                if k == 1
                    currCamFeatIndices = currIndices;
                else
                    currCamFeatIndices = intersect(currCamFeatIndices, currIndices);
                end
            end

            currIndices = currCamFeatIndices;
        else
            currFeat = Feature(self, currVideoName, streams{j}, []);
            currIndices = currFeat.GetFeatureIndices();
        end

        if j == 1
            currFeatureIndices = currIndices;
        else
            currFeatureIndices = intersect(currFeatureIndices, currIndices);
        end
    end

    
    Video = [Video; {currVideoName}];
    FeatureIndices = [FeatureIndices; {currFeatureIndices}];
    
    if self.VerboseLevel > 0
        ProgressBar(i, length(videoNames))
    end
end

status = table(Video, FeatureIndices);
end
