function clipT = GetClipTable(self, varargin)

if nargin == 2
    includeFeatures = varargin{1};
else
    includeFeatures = true;
end

annotIdxs = GetAnnotationIndices(self);
if includeFeatures
    featureIdxs = GetFeatureIndices(self);
else
    FeatureIndices = cell(size(annotIdxs, 1), 1);

    for i = 1:size(annotIdxs, 1)
        FeatureIndices{i} = vertcat(annotIdxs.AnnotatedIndices{i}, annotIdxs.UnannotatedIndices{i});
    end

    featureIdxs = [annotIdxs.Video table(FeatureIndices)];
end

Video = {};
Indices = {};
for i = 1:size(featureIdxs,1)
    currFeatIdxs = featureIdxs.FeatureIndices{i};
    currAnnotIdxs = annotIdxs.AnnotatedIndices{i};

    if isempty(currFeatIdxs) || isempty(currAnnotIdxs)
        continue
    end

    validIdxs = intersect(currFeatIdxs, currAnnotIdxs);
    Video = [Video; featureIdxs.Video{i}];
    Indices = [Indices; {validIdxs}];
end
status = table(Video, Indices);

clipLength = self.ConfigFile.GetParams('ClipLength');
annotClipT = DivideIntoClips(status, clipLength);

typeStr = repmat({'A'}, size(annotClipT, 1), 1);
Type = categorical(typeStr, {'A', 'C', 'UL'});
annotClipT = addvars(annotClipT, Type);

Video = {};
Indices = {};
for i = 1:size(featureIdxs,1)
    currFeatIdxs = featureIdxs.FeatureIndices{i};
    currAnnotIdxs = annotIdxs.UnannotatedIndices{i};

    if isempty(currFeatIdxs) || isempty(currAnnotIdxs)
        continue
    end

    validIdxs = intersect(currFeatIdxs, currAnnotIdxs);
    Video = [Video; featureIdxs.Video{i}];
    Indices = [Indices; {validIdxs}];
end
status = table(Video, Indices);
unAnnotClipT = DivideIntoClips(status, clipLength);

typeStr = repmat({'UL'}, size(unAnnotClipT, 1), 1);
Type = categorical(typeStr, {'A', 'C', 'UL'});
unAnnotClipT = addvars(unAnnotClipT, Type);

if ~isempty(annotClipT)
    unAnnotClipT.ClipNumber = unAnnotClipT.ClipNumber + annotClipT.ClipNumber(end);
end

clipT = [annotClipT; unAnnotClipT];
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
continousSegments = {};

diff = idxs(2:end) ~= idxs(1:end-1)+1;
diffIdxs = find(diff);

startSeg = [1 diffIdxs+1];
endSeg = [diffIdxs length(idxs)];

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