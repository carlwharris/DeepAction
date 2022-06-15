function self = TrainNetwork(self)
isTrn = self.ClipTable.Set == categorical({'Train'});
trnSeqT = SplitClipDataIntoSequences(self, self.ClipTable(isTrn, :));

trainFeats = TransposeCellArrayElements(trnSeqT.Features);

trnLabels =  DeepActionProject.GetLabelsFromTable(trnSeqT);
trainLabels = TransposeCellArrayElements(trnLabels);

tic
[net, info] = trainNetwork(trainFeats, trainLabels, self.Layers, self.TrainingOptions);
time = toc;

time = seconds(time);
time.Format = 'hh:mm:ss';

self.Network = net;

s = struct;
s.TrainingTime = time;
s.TrainingAccuracy = info.TrainingAccuracy;
s.TrainingLoss = info.TrainingLoss;

valAcc = info.ValidationAccuracy;
s.ValidationIterations = find(~isnan(valAcc));
s.ValidationAccuracy = valAcc(~isnan(valAcc));
s.ValidationLoss = info.ValidationLoss(~isnan(valAcc));

if self.ConfigFile.GetParams('VerboseLevel') > 0
    fprintf('\nNetwork training completed\n')

    fprintf('  - Total training time:       %s\n', char(time))
    fprintf('  - Final validation accuracy: %0.1f%%\n', s.ValidationAccuracy(end))
    fprintf('  - Max validation accuracy:   %0.1f%%\n', max(s.ValidationAccuracy(end)))

end

self.Results.Classifier.Training = s;
end
