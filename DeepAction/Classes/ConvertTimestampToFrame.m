function ConvertTimestampToFrame(tsPath, vidPath, outPath)
%CONVERTTIIMESTAMPTOFRAME   Convert time-stamped annotaations to frame index

if iscell(tsPath)
    for i = 1:length(tsPath)
        ConvertSingleSheet(tsPath{i}, vidPath{i}, outPath)
    end
else
    ConvertSingleSheet(tsPath, vidPath, outPath)
end
end

function ConvertSingleSheet(tsPath, vidPath, outPath)

tsTable = readtable(tsPath);

videoTimestamps = GetVideoTimeStamps(vidPath);

tSecs = ConvertTSCellArrayToSeconds(tsTable{:,2});
Start = FindClosestFrameIdxs(tSecs, videoTimestamps);

tSecs = ConvertTSCellArrayToSeconds(tsTable{:,3});
End = FindClosestFrameIdxs(tSecs, videoTimestamps);

Behavior = lower(tsTable{:,1});
frameIdxT = CreateNewTable(Behavior, Start, End);
frameIdxT = CheckTable(frameIdxT)

[folder, name, ext] = fileparts(outPath);

if isempty(ext)
    outFolder = outPath;
    
    [~, name, ext] = fileparts(tsPath);
    outName = [name ext];
else
    outFolder = folder;
    outName = [name ext];
end

if ~isfolder(outFolder)
    mkdir(outFolder)
end

savePath = fullfile(outFolder, outName);

writetable(frameIdxT, savePath);

end

function inT = CheckTable(inT)
for i = size(inT,1):-1:1
    if inT.End(i) < inT.Start(i)
        inT(i,:) = [];
    end
end

end

function frameIdxT = CreateNewTable(Behavior, Start, End)
frameIdxT = table(Behavior, Start, End);
end

function closestIndex = FindClosestFrameIdxs(tSecs, vidTS)
if length(tSecs) > 1
    closestIndex = zeros(length(tSecs),1);
    for i = 1:length(tSecs)
        [~, closestIndex(i)] = min(abs(vidTS-tSecs(i)));
    end
else
    [~,closestIndex] = min(abs(vidTS-tSecs));
end
end

function timeStamps = GetVideoTimeStamps(vidFilePath)
vidReader = VideoReader(vidFilePath);

timeStamps = [];
while hasFrame(vidReader)
    ts = vidReader.CurrentTime;
    timeStamps = [timeStamps; ts];
    readFrame(vidReader);
end
end

function tSecs = ConvertTSCellArrayToSeconds(tsCellArray)
tSecs = zeros(size(tsCellArray));

for i = 1:length(tsCellArray)
    tSecs(i) = ConvertTSStringToSeconds(tsCellArray{i});
end
end

function tSec = ConvertTSStringToSeconds(str)

if iscell(str)
    str = str{1};
end

numbers = [];
for i = 1:length(str)
    if ~isnan(str2double(str(i)))
       numbers = [numbers str2double(str(i))];
    end
end

nEmpty = 6-length(numbers);
numbers = [zeros(1, nEmpty) numbers];

hrs = numbers(1) * 10 + numbers(2);
mins = numbers(3) * 10 + numbers(4);
secs = numbers(5) * 10 + numbers(6);

d = duration(hrs, mins, secs);
tSec = seconds(d);
end