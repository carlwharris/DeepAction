function ExportAnnotations(self)
revPath = fullfile(self.ProjectPath, 'review.mat');
load(revPath, 'ClipTable');

uniqueVideos = unique(ClipTable.Video);

exportFolder = fullfile(self.ProjectPath, 'results', 'annotations');

if ~isfolder(exportFolder)
    mkdir(exportFolder)
end

summaryT = CreateSummaryT(ClipTable);

savePath = fullfile(self.ProjectPath, 'results', 'clip_table_summary.csv');
writetable(summaryT, savePath)

for i = 1:length(uniqueVideos)
    currVideo = uniqueVideos{i};
    currVideoClips = ClipTable(strcmp(currVideo, ClipTable.Video), :);

    currAnnots = vertcat(currVideoClips.Annotations{:});
    currAnnots = sortrows(currAnnots, 'Frame');

    startStopT = CreateStartStopArray(currAnnots);
    saveName = sprintf('annotations-%s.csv', currVideo);
    savePath = fullfile(exportFolder, saveName);
    writetable(startStopT, savePath)

    behavArray = CreateBehaviorArray(currAnnots);
    saveName = sprintf('ethogram-%s.csv', currVideo);
    savePath = fullfile(exportFolder, saveName);
    writetable(behavArray, savePath)
end
end


function outT = CreateBehaviorArray(annotT)
labels = categories(annotT.Label);

behavArray = zeros(size(annotT, 1), length(labels));
for i = 1:length(labels)
    isCurrLabel = annotT.Label == categorical(labels(i));
    behavArray(isCurrLabel, i) = 1;
end

annotT = removevars(annotT, 'Label');

behavArray = array2table(behavArray, 'VariableNames', labels);

outT = [annotT, behavArray];
end

function startStopT = CreateStartStopArray(annotT)
isDiff = annotT.Label(1:end-1) ~= annotT.Label(2:end);
diffIdxs = find(isDiff);

startIdxs = [1; diffIdxs+1];
endIdxs = [diffIdxs; length(isDiff)];

startStopT = table;
for i = 1:length(startIdxs)
    currStart = startIdxs(i);
    currEnd = endIdxs(i);
    currBehav = annotT.Label(currStart);

    currRow = table(currBehav, currStart, currEnd, 'VariableNames', ...
        {'Behavior', 'StartFrame', 'EndFrame'});
    startStopT = [startStopT; currRow];
end
end

function summaryT = CreateSummaryT(clipTable)
clipTable = sortrows(clipTable, 'ClipNumber');

tmpT = table;
for i = 1:size(clipTable,1)
    currAnnot = clipTable.Annotations{i};
    currStartFrame = currAnnot.Frame(1);
    currEndFrame = currAnnot.Frame(end);

    currStartTime = seconds(currAnnot.TimeStamp(1));
    currEndTime = seconds(currAnnot.TimeStamp(end));

    currDuration = currEndTime - currStartTime;

    if hours(currStartTime) < 1
        currStartTime.Format = 'mm:ss';
    else
        currStartTime.Format = 'hh:mm:ss';
    end
    currStartTime = char(currStartTime);

    
    if hours(currEndTime) < 1
        currEndTime.Format = 'mm:ss';
    else
        currEndTime.Format = 'hh:mm:ss';
    end
    currEndTime = char(currEndTime);

    if hours(currDuration) < 1
        currDuration.Format = 'mm:ss';
    else
        currDuration.Format = 'hh:mm:ss';
    end
    currDuration = char(currDuration);

    tmpT = [tmpT; table({currDuration}, {currStartTime}, {currEndTime}, ...
        currStartFrame, currEndFrame, ...
        'VariableNames', {'Duration', 'StartTime', 'EndTime', 'StartFrame', 'EndFrame'})];
end

toInclude = {'ClipNumber', 'Video', 'Type'};
isVar = contains(clipTable.Properties.VariableNames, toInclude);
summaryT = [clipTable(:, isVar), tmpT];

if all(contains(summaryT.Properties.VariableNames, {'Set', 'Accuracy'}))
    isUL = summaryT.Set == categorical({'UL'});
    summaryT.Accuracy(isUL) = nan;
end

end