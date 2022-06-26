function self = CreateClipTable(self, varargin)

p = inputParser;
addOptional(p, 'IncludeFeatures', true);
parse(p,varargin{:});

inclFeats = p.Results.IncludeFeatures;

if self.VerboseLevel > 0
    if inclFeats
        fprintf('  Dividing project annotations & features into clips\n')
    else
        fprintf('  Dividing project video into clips\n')
    end
end

annotIdxs = GetAnnotationIndices(self);
if inclFeats
    featureIdxs = GetFeatureIndices(self);
    
    for i = size(annotIdxs, 1):-1:1
        currFeatIdxs = featureIdxs.FeatureIndices{i};
        annotIdxs.AnnotatedIndices{i} = intersect(annotIdxs.AnnotatedIndices{i}, currFeatIdxs);
        annotIdxs.UnannotatedIndices{i} = intersect(annotIdxs.UnannotatedIndices{i}, currFeatIdxs);
    end
end


clipLength = self.ConfigFile.GetParams('ClipLength');
fps = self.GetAverageFrameRate();

annotatedT = table(annotIdxs.Video, annotIdxs.AnnotatedIndices, 'VariableNames', ...
    {'Video', 'Indices'});
annotatedT = DivideIntoClips(annotatedT, clipLength * fps);

typeStr = repmat({'R'}, size(annotatedT, 1), 1);
typeCat = categorical(typeStr, {'R', 'UR'});
annotatedT = addvars(annotatedT, typeCat, 'NewVariableNames', 'Type');

unannotatedT = table(annotIdxs.Video, annotIdxs.UnannotatedIndices, 'VariableNames', ...
    {'Video', 'Indices'});
unannotatedT = DivideIntoClips(unannotatedT, clipLength * fps);
typeStr = repmat({'UR'}, size(unannotatedT, 1), 1);
typeCat = categorical(typeStr, {'R', 'UR'});
unannotatedT = addvars(unannotatedT, typeCat, 'NewVariableNames', 'Type');

if ~isempty(annotatedT) && ~isempty(unannotatedT)
    unannotatedT.ClipNumber = unannotatedT.ClipNumber + annotatedT.ClipNumber(end);
end

clipT = [annotatedT; unannotatedT];

clipT = addvars(clipT, zeros(size(clipT, 1), 1), zeros(size(clipT, 1), 1), ...
    'NewVariableNames', {'StartFrame', 'EndFrame'});
for i = 1:size(clipT, 1)
    clipT.StartFrame(i) = clipT.Indices{i}(1);
    clipT.EndFrame(i) = clipT.Indices{i}(end);
end

self.ClipTable = removevars(clipT, 'Indices');

verboseLvl = self.ConfigFile.GetParams('VerboseLevel');
% 
% if verboseLvl > 0
%     tmpLenSec = seconds(clipLength);
%     tmpLenSec.Format = 'hh:mm:ss';
%     fprintf('  - Created %d clips with a target length of %s (%0.0f frames on avg. with FPS of %0.1f)\n', size(clipT), char(tmpLenSec), clipLength * fps, fps)
%     fprintf('    - %d are human-annotated\n', size(annotatedT, 1))
%     fprintf('    - %d do not have human annotations\n', size(unannotatedT, 1))
% end

end

function outT = DivideIntoClips(inTable, clipLength)
ClipNumber = [];
Video = {};
Indices = {};

clipCnt = 1;
for i = 1:size(inTable,1)
    currVid = inTable.Video{i};
    currIndices = inTable.Indices{i};
    
    continuousAnnot = splitIdxsIntoContinuous(currIndices);
    for j = 1:length(continuousAnnot)
        clipIdxs = splitSegmentIntoClipIndices(continuousAnnot{j}, clipLength);

        

        for k = 1:length(clipIdxs)
            
            ClipNumber = [ClipNumber; clipCnt];
            Video = [Video; currVid];
            Indices = [Indices; clipIdxs{k}];
            clipCnt = clipCnt + 1;
        end 
    end
end

outT = table(ClipNumber, Video, Indices);
end


function continousSegments = splitIdxsIntoContinuous(idxs)
if isempty(idxs)
    continousSegments = {};
    return
end
continousSegments = {};

diff = idxs(2:end) ~= idxs(1:end-1)+1;
diffIdxs = find(diff);

startSeg = [1; diffIdxs+1];
endSeg = [diffIdxs; length(idxs)];

for i = 1:length(startSeg)
    currIdxs = idxs(startSeg(i):endSeg(i));
    continousSegments{i} = currIdxs;
end
end

function clipIdxs = splitSegmentIntoClipIndices(idxs, clipLength)
nSplits = round(length(idxs) / clipLength);

if nSplits == 0
    clipIdxs = {idxs};
    return
end

splitIdxs = linspace(0, length(idxs), nSplits+1);
splitIdxs = round(splitIdxs);

startSplit = splitIdxs(1:end-1)+1;
endSplit = splitIdxs(2:end);

clipIdxs = {};
for i = 1:length(startSplit)
    currClipIdxs = idxs(startSplit(i):endSplit(i));
    clipIdxs{i} = currClipIdxs;
end
end