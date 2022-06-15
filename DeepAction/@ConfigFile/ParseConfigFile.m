function configFileParams = ParseConfigFile(self)
contents = fileread(self.FilePath);
lines = strsplit(contents, '\n', 'CollapseDelimiters', false);  

sectionTitles = ["[Project]", "[Stream]", "[Features]", "[Annotations]",...
    "[Classifier]", "[TrainingOptions]", "[Evaluation]", ...
    "[ConfidenceScoring]"];
startSectionIdxs = find(contains(lines, sectionTitles));
endSectionIdxs = [startSectionIdxs(2:end)-1 length(lines)];

configFileParams = struct;
for i = 1:length(startSectionIdxs)
    currSection = lines{startSectionIdxs(i)};
    currSectionIdxs = startSectionIdxs(i):endSectionIdxs(i);
    currLines = lines(currSectionIdxs);
    
    if contains(currSection, '[Project]')
        configFileParams.Project = ParseProjectSection(currLines);
    end
    
    if contains(currSection, '[Stream]')
        configFileParams.Stream = ParseStreamSection(currLines);
    end
    
    if contains(currSection, '[Features]')
        configFileParams.Features = ParseFeaturesSection(currLines);
    end
    
    if contains(currSection, '[Annotations]')
        configFileParams.Annotations = ParseAnnotationsSection(currLines);
    end
    
    if contains(currSection, '[Classifier]')
        configFileParams.Network = ParseClassifierSection(currLines);
    end
    
    if contains(currSection, '[TrainingOptions]')
        configFileParams.TrainingOptions = ParseTrainingOptionsSection(currLines);
    end
    
    if contains(currSection, '[Evaluation]')
        configFileParams.Evaluation = ParseEvaluationSection(currLines);
    end
    
    if contains(currSection, '[ConfidenceScoring]')
        configFileParams.ConfidenceScoring = ParseConfidenceScoringSection(currLines);
    end
end
end

function s = ParseProjectSection(lines)
s = struct;

s.CameraNames = [];
for i = 1:length(lines)
    tline = lines{i};
    
    if contains(tline, 'ProjectName', 'IgnoreCase', true)
        s.ProjectName = ParseString(tline);
    end
    
    if contains(tline, 'MultipleCameras', 'IgnoreCase', true)
        s.MultipleCameras = ParseTrueFalse(tline);
    end
    
    if contains(tline, 'CameraNames')
        s.CameraNames = ParseBrackets(tline);
    end

    if contains(tline, 'PrimaryCamera')
        s.PrimaryCamera = ParseString(tline);
    end
    
    if contains(tline, 'VerboseLevel')
        s.VerboseLevel = ParseNumber(tline);
    end
end
end

function s = ParseStreamSection(lines)

s = struct;
for i = 1:length(lines)
    tline = lines{i};
    
    if contains(tline, 'ImageType')
        k = strfind(tline,'=');
        tline = tline(k+1:end);
        if contains(tline, 'seq', 'IgnoreCase',true)
            s.ImageType = 'sequence';
        elseif contains(tline, 'img', 'IgnoreCase',true) || contains(tline, 'image', 'IgnoreCase',true)
            s.ImageType = 'image';
        elseif contains(tline, 'video', 'IgnoreCase',true) || contains(tline, 'mp4', 'IgnoreCase',true)
            s.ImageType = 'video';
        end
    end

    if contains(tline, 'SpatialStream')
        s.SpatialStream = ParseTrueFalse(tline);
    end

    if contains(tline, 'TemporalStream')
        s.TemporalStream = ParseTrueFalse(tline);
    end

    if contains(tline, 'ImageExtension')
        k = strfind(tline,'=');
        tline = tline(k+1:end);

        if contains(tline, 'mp4', 'IgnoreCase',true)
            s.ImageExtension = 'mp4';
        elseif contains(tline, 'avi', 'IgnoreCase',true)
            s.ImageExtension = 'avi';
        elseif contains(tline, 'seq', 'IgnoreCase',true)
            s.ImageExtension = 'seq';
        elseif contains(tline, 'png', 'IgnoreCase',true)
            s.ImageExtension = 'png';    
        elseif contains(tline, 'jpg', 'IgnoreCase',true)
            s.ImageExtension = 'jpg';
        end
    end

    if contains(tline, 'Method')
        if contains(tline, 'TV-L1', 'IgnoreCase',true) || contains(tline, 'TVL1', 'IgnoreCase',true)
            s.Method = 'TV-L1';
        elseif contains(tline, 'Farneback', 'IgnoreCase',true)
            s.Method = 'Farneback';
        end
    end
    
    if contains(tline, 'ResizeFlow')
        s.ResizeFlow = ParseTrueFalse(tline);
    end
    
    if contains(tline, 'FlowImageSize')
        k = strfind(tline,'=');
        tline = tline(k+1:end);

        split = strsplit(tline,',');

        vals = zeros(1, length(split));
        for j = 1:length(split)
            currSplit = split{j};
            toKeep = isstrprop(currSplit,'digit');
            currSplit(~toKeep)=[];
            vals(j) = str2double(currSplit);
        end
        
        s.FlowImageSize = vals;
    end
end

if s.SpatialStream == true
    if s.TemporalStream == true
        s.Streams = {'spatial', 'temporal'};
    else
        s.Streams = {'spatial'};
    end
elseif s.SpatialStream == false
    if s.TemporalStream == true
        s.Streams = {'temporal'};
    else
        s.Streams = {};
    end
end
end

function s = ParseFeaturesSection(lines)

s = struct;
for i = 1:length(lines)
    tline = lines{i};
    
    if contains(tline, 'FeatureExtractor')
        k = strfind(tline,'=');
        tline = tline(k+1:end);

        if contains(tline, 'ResNet50', 'IgnoreCase',true)
            s.FeatureExtractor = 'ResNet50';
        elseif contains(tline, 'ResNet18', 'IgnoreCase',true)
            s.FeatureExtractor = 'ResNet18';
        elseif contains(tline, 'GoogLeNet', 'IgnoreCase',true)
            s.FeatureExtractor = 'GoogLeNet';
        elseif contains(tline, 'VGG-16', 'IgnoreCase',true)
            s.FeatureExtractor = 'VGG-16';
        elseif contains(tline, 'VGG-19', 'IgnoreCase',true)
            s.FeatureExtractor = 'VGG-19';
        elseif contains(tline, 'InceptionResNetv2', 'IgnoreCase',true)
            s.FeatureExtractor = 'InceptionResNetv2';        
        end
    end

    if contains(tline, 'CNNMiniBatchSize')
        s.CNNMiniBatchSize = ParseNumber(tline);
    end
    
    if contains(tline, 'FlowStackSize')
        s.FlowStackSize = ParseNumber(tline);
    end
    
    if contains(tline, 'ReduceDimensionality')
        s.ReduceDimensionality = ParseTrueFalse(tline);
    end
    
    if contains(tline, 'NumDimensions')
        s.NumDimensions = ParseNumber(tline);
    end
    
    if contains(tline, 'SamplePoints')
        s.SamplePoints = ParseNumber(tline);
    end
    
    if contains(tline, 'IterationLimit')
        s.IterationLimit = ParseNumber(tline);
    end
end
end

function s = ParseAnnotationsSection(lines)
s = struct;
for i = 1:length(lines)
    tline = lines{i};
    
    if contains(tline, 'ClipLength')
        s.ClipLength = ParseNumber(tline);
    end
    
    if contains(tline, 'MutuallyExclusiveBehaviors')
        s.MutuallyExclusiveBehaviors = ParseTrueFalse(tline);
    end
end

[s.Behaviors, s.Keys] = ParseBehaviors(lines);

end


function s = ParseClassifierSection(lines)
s = struct;
for i = 1:length(lines)
    tline = lines{i};
    
    if contains(tline, 'SequenceLength')
        s.SequenceLength = ParseNumber(tline);
    end
    
    if contains(tline, 'NumberHiddenUnits', 'IgnoreCase', true)
        s.NumberHiddenUnits = ParseNumber(tline);
    end
    
    if contains(tline, 'NumberLayers', 'IgnoreCase', true)
        s.NumberLayers = ParseNumber(tline);
    end
    
    if contains(tline, 'DropoutRatio', 'IgnoreCase', true)
        s.DropoutRatio = ParseNumber(tline);
    end
    
    if contains(tline, 'ClassificationLayer', 'IgnoreCase',true)
        if contains(tline, 'weighted cross-entropy', 'IgnoreCase',true)
            s.ClassificationLayer = 'weighted cross-entropy';
        elseif contains(tline, 'cross-entropy', 'IgnoreCase',true)
            s.ClassificationLayer = 'cross-entropy';
        end
    end
        
end
end

function s = ParseTrainingOptionsSection(lines)
s = struct;
for i = 1:length(lines)
    tline = lines{i};
    
    
    if contains(tline, 'MiniBatchSize')
        s.MiniBatchSize = ParseNumber(tline);
    end
    
    if contains(tline, 'MaxExpochs')
        s.MaxExpochs = ParseNumber(tline);
    end
    
    if contains(tline, 'ValidationFreqEpoch')
        s.ValidationFreqEpoch = ParseNumber(tline);
    end
    
    if contains(tline, 'ValidationPatience')
        s.ValidationPatience = ParseNumber(tline);
    end
    
    if contains(tline, 'InitialLearningRate')
        s.InitialLearningRate = ParseNumber(tline);
    end
    
    if contains(tline, 'LearningRateDropPeriod')
        s.LearningRateDropPeriod = ParseNumber(tline);
    end
    
    if contains(tline, 'LearningRateDropFactor')
        s.LearningRateDropFactor = ParseNumber(tline);
    end    
end
end

function s = ParseEvaluationSection(lines)
s = struct;
for i = 1:length(lines)
    tline = lines{i};
    
    if contains(tline, 'PredictionMiniBatchSize')
        s.PredictionMiniBatchSize = ParseNumber(tline);
    end
    
    if contains(tline, 'TrainProportion')
        s.TrainProportion = ParseNumber(tline);
    end
    
    if contains(tline, 'ValidationProportion')
        s.ValidationProportion = ParseNumber(tline);
    end
    
    if contains(tline, 'TestProportion')
        s.TestProportion = ParseNumber(tline);
    end
end
end

function s = ParseConfidenceScoringSection(lines)

s = struct;
for i = 1:length(lines)
    tline = lines{i};
    if contains(tline, 'ScoringMethod')
        if contains(tline, 'scaling', 'IgnoreCase',true)
            s.ScoringMethod = 'TemperatureScaling';
        else
            s.ScoringMethod = 'MaxSoftmax';
        end
    end
end
end

function cellArray = ParseBrackets(tline)
k = strfind(tline,'=');
tline = tline(k+1:end);
k = strfind(tline,'[');
tline = tline(k+1:end);
k = strfind(tline,']');
tline = tline(1:k-1);

split = strsplit(tline,',');

cellArray = {};
for j = 1:length(split)
    currSplit = split{j};
    toKeep = isstrprop(currSplit,'alphanum') | ismember(currSplit, '!@_%$#()<>?[]-');
    currSplit(~toKeep)=[];
    
    if ~isempty(currSplit)
        cellArray = [cellArray; {currSplit}];
    end
end

end

function outStr = ParseString(tline)
k = strfind(tline,'=');
outStr = tline(k+1:end);

toKeep = isstrprop(outStr,'alphanum') | isstrprop(outStr,'wspace') | ismember(outStr, '!@_%$#()<>?[]-');
outStr = outStr(toKeep);
end

function outNum = ParseNumber(tline)
k = strfind(tline,'=');

if ~isempty(k)
    tline = tline(k+1:end);
end

outNum = str2double(tline);
end

function tf = ParseTrueFalse(tline)
k = strfind(tline,'=');

if ~isempty(k)
    tline = tline(k+1:end);
end

if contains(tline, 'true', 'IgnoreCase',true)
    tf = true;
elseif contains(tline, 'false', 'IgnoreCase',true)
    tf = false;
end
end







function outS = ParseLines(lines)

outS = struct;
for i = 1:length(lines)
    tline = lines{i};
    [fieldname, value] = ParseLine(tline);
    
    if ~isempty(fieldname)
        outS.(fieldname) = value;
    end
end

behaviors = ParseBehaviors(lines);

if ~isempty(behaviors)
    outS.Behaviors = behaviors;
end
end

function [behaviors, keys] = ParseBehaviors(lines)
if any(contains(lines, 'Behaviors', 'IgnoreCase',true))
    idx = find(contains(lines, 'Behaviors', 'IgnoreCase',true), 1);
    lines = lines(idx+1:end);
    
    behaviors = {};
    keys = {};
    
    for i = 1:length(lines)
        if contains(lines{i}, '-')
            k = strfind(lines{i},'(');
            behaviorHalf = lines{i}(1:k);
            keyHalf = lines{i}(k+1:end);
            behaviors = [behaviors; RemoveNonLetterNonNumeric(behaviorHalf)];
            keys = [keys; RemoveNonLetterNonNumeric(keyHalf)];
        end
    end
else
    behaviors = {};
    keys = {};
end
end

function line = RemoveNonLetterNonNumeric(line)
toKeep = false(1, length(line));

for i = 1:length(line)
    if isletter(line(i)) == true
        toKeep(i) = true;
    end
    
    if ~isnan(str2double(line(i))) == true
        toKeep(i) = true;
    end
end

line = line(toKeep);
end

function [fieldname, value] = ParseLine(line)
if isempty(line) 
    fieldname = [];
    value = [];
    return
end

k = strfind(line,'=');

if isempty(k)
    fieldname = [];
    value = [];
    return
end

initFN = line(1:k-1);
initVal = line(k+1:end);

fieldname = initFN(isletter(initFN));

if contains(initVal, '[')
    k = strfind(initVal,'[');
    initVal = initVal(k+1:end);
    
    k = strfind(initVal,']');
    initVal = initVal(1:k-1);
    
    split = strsplit(initVal,',');
    
    value = {};
    for j = 1:length(split)
        currSplit = split{j};
        currSplit = currSplit(isletter(currSplit));
        value = [value currSplit];
    end
    
    if isempty(value)
        value = [];
    end
    
    return
end

if contains(initVal, 'true', 'IgnoreCase',true)
    value = true;
    return
end

if contains(initVal, 'false', 'IgnoreCase',true)
    value = false;
    return
end

if contains(initVal, '''')
    k = strfind(initVal,'''');
    value = initVal(k(1)+1:k(2)-1);
    return
end

if ~isnan(str2double(initVal))
    value = str2double(initVal);
    return
end

end