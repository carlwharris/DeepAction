function clipT = LoadFeatures(self, clipT)
streams = self.ConfigFile.GetParams('Streams');
clipTCollapsed = CollapseClips(clipT);

reduceDim = false;
if self.ConfigFile.GetParams('ReduceDimensionality')
    [RICAModel, ~] = LoadRICAModel(self);
    
    if isempty(RICAModel)
        reduceDim = false;
    else
        reduceDim = true;
    end
end

Features = cell(size(clipT,1), 1);

if self.VerboseLevel > 0
    if reduceDim
        fprintf('    Loading features and reducing dimensionality  ')
    else
        fprintf('    Loading features  ')
    end
end

for i = 1:size(clipTCollapsed,1)
    vidName = clipTCollapsed.Video{i};
    vidRows = clipTCollapsed.Rows{i};
    
    currFeatures = [];
    for j = 1:length(streams) 
        stream = streams{j};
        if self.ConfigFile.GetParams('MultipleCameras') == true
            camNames = self.ConfigFile.GetParams('CameraNames');
            for k = 1:length(camNames)
                currFeat = Feature(self, vidName, stream, camNames{k});
                feat = currFeat.LoadFeatures();
                
                if ~isempty(currFeatures)
                    if size(feat,1) > size(currFeatures,1)
                        feat = feat(1:size(currFeatures,1), :);
                    end

                    if size(feat,1) < size(currFeatures,1)
                        currFeatures = currFeatures(1:size(feat,1), :);
                    end
                end
            
                currFeatures = [currFeatures feat];
            end
        else
            currFeat = Feature(self, vidName, stream, []);
            feat = currFeat.LoadFeatures();
            
            if ~isempty(currFeatures)
                if size(feat,1) > size(currFeatures,1)
                    feat = feat(1:size(currFeatures,1), :);
                end
                
                if size(feat,1) < size(currFeatures,1)
                    currFeatures = currFeatures(1:size(feat,1), :);
                end
            end
            
            currFeatures = [currFeatures feat];
        end
    end

    for j = 1:size(vidRows,1)
        currParentTRow = vidRows.RowNumber(j);
        
        if any(strcmpi(vidRows.Properties.VariableNames, 'StartFrame'))
            currIndices = vidRows.StartFrame(j):vidRows.EndFrame(j);
        elseif any(strcmpi(vidRows.Properties.VariableNames, 'Indices'))
            currIndices = vidRows.Indices{j};
        elseif any(strcmpi(vidRows.Properties.VariableNames, 'FeatureIndices'))
            currIndices = vidRows.FeatureIndices{j};
        end

        currRowFeatures = currFeatures(currIndices,:);

        if reduceDim == true
            currRowFeatures = transform(RICAModel,  currRowFeatures);
        end
        Features{currParentTRow} = currRowFeatures;
    end

    if self.VerboseLevel > 0
        ProgressBar(i, size(clipTCollapsed,1))
    end
end
clipT = addvars(clipT, Features);
end

function clipT = CollapseClips(clipT)
RowNumber = [1:size(clipT)]';

clipT = addvars(clipT, RowNumber);
uniqueVideos = unique(clipT.Video);

Video = {};
Rows = {};
for i = 1:length(uniqueVideos)
    currVideo = uniqueVideos{i};
    
    currVid = clipT(strcmp(clipT.Video, currVideo), :);
    
    Video = [Video; currVideo];
    Rows = [Rows; {currVid}];
end

clipT = table(Video, Rows);
end
