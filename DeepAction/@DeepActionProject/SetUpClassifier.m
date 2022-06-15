
function self = SetUpClassifier(self, varargin)
p = inputParser;
p.KeepUnmatched=true;
addOptional(p, 'showplot', true);
parse(p,varargin{:});


verboseLevl = self.VerboseLevel;

trnOpts = self.ConfigFile.GetParams('TrainingOptions');
netOpts = self.ConfigFile.GetParams('Network');

if verboseLevl > 0
    fprintf('Setting up network...\n')
end

% valDataT = self.NetworkData.Validate;

isVal = self.ClipTable.Set == categorical({'Validate'});
valSeqT = SplitClipDataIntoSequences(self, self.ClipTable(isVal, :));

valLabels = DeepActionProject.GetLabelsFromTable(valSeqT);

feats = TransposeCellArrayElements(valSeqT.Features);
valLabels = TransposeCellArrayElements(valLabels);

valFreqEpoch = trnOpts.ValidationFreqEpoch;
mbSize = trnOpts.MiniBatchSize;

isTrn = self.ClipTable.Set == categorical({'Train'});
trnSeqT = SplitClipDataIntoSequences(self, self.ClipTable(isTrn, :));

trnLabels = DeepActionProject.GetLabelsFromTable(trnSeqT);
nItersEpoch = floor(size(trnSeqT,1) / mbSize);
valPat = trnOpts.ValidationPatience;

addOpts = {};           
addOpts(:,end+1) = {'ValidationData'; {feats, valLabels}};
addOpts(:,end+1) = {'ValidationFrequency'; valFreqEpoch * nItersEpoch};
addOpts(:,end+1) = {'ValidationPatience'; valPat};

if p.Results.showplot
    addOpts(:,end+1) = {'Plots'; 'training-progress'};
end

if verboseLevl > 0
    addOpts(:,end+1) = {'Verbose'; true};
    addOpts(:,end+1) = {'VerboseFrequency'; nItersEpoch};
end

opts = trainingOptions(...
  'adam', ...
  'MiniBatchSize'       , mbSize, ...
  'InitialLearnRate'    , trnOpts.InitialLearningRate, ...
  'LearnRateDropPeriod' , trnOpts.LearningRateDropPeriod, ...
  'LearnRateDropFactor' , trnOpts.LearningRateDropFactor, ...
  'LearnRateSchedule'   , 'piecewise', ...
  'GradientThreshold'   , 2, ...
  'MaxEpochs'           , trnOpts.MaxExpochs, ...
  'Shuffle'             , 'every-epoch', ...
  addOpts{:});

if verboseLevl > 0
    fprintf('  Training options\n')
    fprintf('    - MiniBatchSize: %d\n', mbSize)
    fprintf('    - InitialLearnRate: %0.6f\n', trnOpts.InitialLearningRate)
    fprintf('    - LearnRateDropPeriod: %d\n', trnOpts.LearningRateDropPeriod)
    fprintf('    - LearnRateDropFactor: %0.3f\n', trnOpts.LearningRateDropFactor)
    fprintf('    - MaxEpochs: %d\n', trnOpts.MaxExpochs)
end

nLayers = netOpts.NumberLayers;
nHU = netOpts.NumberHiddenUnits;
doRatio = netOpts.DropoutRatio;
bilstmLayers = [];
for i = 1:nLayers
    currLayerName = sprintf('Bilstm%d', i);
    currLayerCmd = sprintf('bilstmLayer(%d, ''OutputMode'', ''sequence'', ''Name'', ''%s'')', ...
        nHU, currLayerName);
    bilstmLayers = [bilstmLayers; eval(currLayerCmd)];

    currLayerCmd = sprintf('dropoutLayer(%0.2f)', doRatio);
    bilstmLayers = [bilstmLayers; eval(currLayerCmd)];
end

classLayerName = self.ConfigFile.GetParams('ClassificationLayer');

if strcmp(classLayerName, 'cross-entropy')
    finalLayers = [softmaxLayer('Name', 'softmax'); classificationLayer];
elseif strcmp(classLayerName, 'weighted cross-entropy')
    trainLbls = vertcat(trnLabels{:});
    catCntTrn = countcats(trainLbls);
    
    valLbls = vertcat(valLabels{:});
    catCntVal = countcats(valLbls);
    
    catCnt = catCntTrn + catCntVal;
    catsStr = categories(trainLbls);

    isMissing = catCnt == 0;
    
    classWeights = 1 ./ catCnt;
    classWeights(isMissing) = 1e-8;
    classWeights = classWeights' / mean(classWeights);

    finalLayers = [...
        softmaxLayer('Name', 'softmax');
        classificationLayer('Classes', catsStr, 'ClassWeights', classWeights)];
end

nFeatures = size(feats{1}, 1);
nClasses = length(categories(valLabels{1}));
layers = [ ...
    sequenceInputLayer(nFeatures, 'Name',  'Input')
    bilstmLayers
    fullyConnectedLayer(nClasses, 'Name', 'FC')
    finalLayers];

if verboseLevl > 0
    fprintf('  Network options\n')
    fprintf('    - Classification layer: %s\n', classLayerName)
    fprintf('    - NumberLayers: %d\n', nLayers)
    fprintf('    - NumberHiddenUnits: %d\n', nHU)
    fprintf('    - DropoutRatio: %0.3f\n', doRatio)
    fprintf('  Network input\n')
    fprintf('    - NumItersEpoch: %d\n', nItersEpoch)
    fprintf('    - NumberFeatures: %d\n', nFeatures)
    fprintf('    - NumberClasses: %d\n\n', nClasses)
end

self.Layers = layers;
self.TrainingOptions = opts;
end
