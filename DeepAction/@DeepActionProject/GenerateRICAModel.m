function GenerateRICAModel(self)
[RICAModel, path] = LoadRICAModel(self);

if ~isempty(RICAModel)
    prompt = 'RICAModel already exists, do you want to overwrite it? (y/n) ';
    response = input(prompt, 's');
    if strcmpi(response, 'n') || strcmp(response, 'no')
        return
    elseif strcmpi(response, 'y') || strcmp(response, 'yes')
        delete(path)
    else
        fprintf('Invalid response!')
        return
    end
end

verboseLevl = self.VerboseLevel;
if verboseLevl > 0
    fprintf('Generating RICA model...\n')
end

status = GetFeatureIndices(self);
desiredDim = self.ConfigFile.GetParams('NumDimensions');

modelFolder = fullfile(self.ProjectPath, 'rica_models');

samplePts = self.ConfigFile.GetParams('SamplePoints');
totalPoints = length(vertcat(status.FeatureIndices{:}));

if samplePts <= 1
    nSamplePoints = round(samplePts * totalPoints);
else
    nSamplePoints = samplePts;
end

if verboseLevl > 0
    fprintf('  - Number of sample points: %d\n', nSamplePoints)
end

selectedPoints = status;
for i = 1:size(status,1)
    currIndices = status.FeatureIndices{i};
    nIndicesCurrRow = length(currIndices);

    propCurrIndices = nIndicesCurrRow / totalPoints;
    nPointsSampleCurr = round(nSamplePoints * propCurrIndices);

    selIndices = randsample(currIndices, nPointsSampleCurr);
    selectedPoints.Indices{i} = selIndices;
end
selectedPoints = removevars(selectedPoints, 'FeatureIndices');
status = LoadFeatures(self, selectedPoints);
features = vertcat(status.Features{:});

maxIters = self.ConfigFile.GetParams('IterationLimit');

if verboseLevl > 0
    fprintf('  - Reducing dimensionality from %d to %d (max iters=%d)\n', ...
            size(features, 2), desiredDim, maxIters);
end

if verboseLevl > 0
    ricaVerb = 1;
else
    ricaVerb = 0;
end

RICAModel = rica(features, desiredDim, 'IterationLimit', maxIters, 'VerbosityLevel', ricaVerb);

mdlOutPath = GetOutputPath(modelFolder);

Info = struct;
Info.Streams = self.ConfigFile.GetParams('Streams');
Info.CameraNames = self.ConfigFile.GetParams('CameraNames');
Info.NumDimensions = self.ConfigFile.GetParams('NumDimensions');

save(mdlOutPath, 'RICAModel', 'Info');
end

function outPath = GetOutputPath(modelFolder)

if ~isfolder(modelFolder)
    mkdir(modelFolder)
end

currIdx = 0;
stopFlag = false;
while stopFlag == false

    outName = sprintf('RICAModel_%d.mat', currIdx);
    outPath = fullfile(modelFolder, outName);
    
    if ~isfile(outPath)
        stopFlag = true;
    end
    
    currIdx = currIdx + 1;
end

end