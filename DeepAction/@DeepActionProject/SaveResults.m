function SaveResults(self, varargin)
if self.VerboseLevel > 1
    fprintf('Saving results...\n')
end

Results = self.Results;

Clips = struct;
Clips.Train = CreateClipDataToSave(self.NetworkData.Train);
Clips.Validate = CreateClipDataToSave(self.NetworkData.Validate);
Clips.Test = CreateClipDataToSave(self.NetworkData.Test);

Config = self.ConfigFile.GetAllParams();

resultsFolder = fullfile(self.ProjectPath, 'results');
if ~isfolder(resultsFolder)
    if self.VerboseLevel > 1
        fprintf('  - Creating results folder\n')
    end
    
    mkdir(resultsFolder)
end

if nargin == 2
    outPath = GetOutputPathWithTag(resultsFolder, varargin{1});
else
    outPath = GetOutputPathNoTag(resultsFolder);
end

if self.VerboseLevel > 1
    fprintf('  - Saving results, clips, and project configuration\n')
end

save(outPath, 'Results', 'Clips', 'Config')

if self.VerboseLevel > 1
    [~, name, ext] = fileparts(outPath);
    name = [name ext];
    fprintf('  - Results saved under /results/%s\n', name)
end
end

function outPath = GetOutputPathWithTag(resultsFolder, tag)
if ~isfolder(resultsFolder)
    mkdir(resultsFolder)
end
if isnumeric(tag)
    outName = sprintf('results_%d.mat', tag);
else
    outName = sprintf('results_%s.mat', tag);
end
outPath = fullfile(resultsFolder, outName);
end

function outPath = GetOutputPathNoTag(resultsFolder)
if ~isfolder(resultsFolder)
    mkdir(resultsFolder)
end

currIdx = 0;
stopFlag = false;
while stopFlag == false
    outName = sprintf('results_%d.mat', currIdx);
    
    outPath = fullfile(resultsFolder, outName);
    
    if ~isfile(outPath)
        stopFlag = true;
    end
    
    currIdx = currIdx + 1;
end
end

function clipT = CreateClipDataToSave(seqT)
clipT = CollapseSequencesIntoClips(seqT);
clipT = clipT(:, {'ClipNumber', 'Video', 'Indices', 'Annotations', 'Predictions'});

StartIndex = zeros(size(clipT, 1), 1);
EndIndex = zeros(size(clipT, 1), 1);

for i = 1:size(clipT, 1)
    StartIndex(i) = clipT.Indices{i}(1);
    EndIndex(i) = clipT.Indices{i}(end);
end

clipT = addvars(clipT, StartIndex, EndIndex, 'After', 'Video');
clipT = removevars(clipT, 'Indices');
end