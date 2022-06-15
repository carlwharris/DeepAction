function seqT = SplitClipDataIntoSequences(self, clipT)

seqLen = self.ConfigFile.GetParams('SequenceLength');


ClipNumber = [];
Video = {};
Type = [];
colNames = clipT.Properties.VariableNames;

singleValPerClipVars = {};
for i = 1:length(colNames)
    currVar = colNames{i};
    if iscell(clipT.(currVar))
        if size(clipT.(currVar){1},1) == 1
            singleValPerClipVars = [singleValPerClipVars {currVar}];
        end
    else
        singleValPerClipVars = [singleValPerClipVars {currVar}];
    end
end

clipWiseData = struct;
allSeqData = [];

seqT = table;

for i = 1:size(clipT,1)
    
    currSeq = [];
    for colNo = 1:size(clipT,2)
        currCol = clipT.Properties.VariableNames{colNo};
        isSingleVarPerClipVar = any(strcmpi(currCol, singleValPerClipVars));
        
        if ~isSingleVarPerClipVar
            seqIdxs = SplitArrayIntoSequences(clipT{i,colNo}{1}, seqLen);
            currSeq = [currSeq seqIdxs];
        end
    end
    
    allSeqData = [allSeqData; currSeq];
    
    colIdxs = find(ismember(colNames, singleValPerClipVars));
    for j = 1:length(seqIdxs)
        seqT = [seqT; clipT(i, colIdxs)];
    end
%     for j = 1:length(seqIdxs)
%         ClipNumber = [ClipNumber; clipT.ClipNumber(i)];
%         Video = [Video; clipT.Video{i}];
%         Type = [Type; clipT.Type(i)];
%     end
end


colNames = colNames(~ismember(colNames, singleValPerClipVars));
for i = 1:length(colNames)
    seqT = addvars(seqT, allSeqData(:,i), 'NewVariableNames', colNames{i});
end
end

function seqIdxs = SplitArrayIntoSequences(array, seqLen)
nSplits = round(size(array,1) / seqLen);

if nSplits == 0
    seqIdxs = {array};
    return
end

splitIdxs = linspace(0, size(array,1), nSplits+1);
splitIdxs = round(splitIdxs);

startSplit = splitIdxs(1:end-1)+1;
endSplit = splitIdxs(2:end);

seqIdxs = cell(length(startSplit),1);
for i = 1:length(startSplit)
    currSeqIdxs = array(startSplit(i):endSplit(i), :);
    seqIdxs{i} = currSeqIdxs;
end
end