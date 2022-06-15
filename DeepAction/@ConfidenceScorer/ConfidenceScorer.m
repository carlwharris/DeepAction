classdef ConfidenceScorer < DeepActionProject
    properties
        Method
        Temperature
    end

    methods
        function self = ConfidenceScorer(project, method)
            self = self@DeepActionProject(project.ProjectPath)

            self.Network = project.Network;
            self.Method = method;

            if self.VerboseLevel > 0
                fprintf('Intializing confidence scorer\n')
            end
        end

        function self = TrainConfidenceScorer(self, trainClipT)
            if ~strcmpi(self.Method, 'TemperatureScaling')
                return
            end

            seqT = self.SplitClipDataIntoSequences(trainClipT);

            if self.VerboseLevel > 0
                fprintf('Training confidence scorer using %s\n', self.Method)
            end

            temp = TrainTemperatureScaler(self, seqT);
            self.Temperature = temp;

            if self.VerboseLevel > 0
                fprintf('  - Sequence calibrator trained\n')
            end
        end

        [summaryS, calClipT, revClipT] = EvaluateScorer(self, clipData)

        function clipT = GenerateClipScores(self, clipT)
            seqT = self.SplitClipDataIntoSequences(clipT);

            if strcmpi(self.Method, 'MaxSoftmax')
                clipT = ScoreSequencesMaxSoftmax(self, seqT);
            elseif strcmpi(self.Method, 'TemperatureScaling')
                clipT = ScoreSequencesTemperatureScaling(self, seqT);
            end

            clipT = CalculateAverageClipScore(clipT);

        end

        function [summaryS, clipT] = EvaluateCalibration(self, clipT)
            Accuracy = clipT.Accuracy;
            PredictedAccuracy = clipT.Score;

            nResponses = zeros(size(clipT, 1), 1);
            for i = 1:size(clipT, 1)
                nResponses(i) = size(clipT.Annotations{i},1);
            end
            inflationFactor = nResponses / mean(nResponses);

            pe = clipT.Accuracy - clipT.Score;
            ae = abs(pe);

            PredictionError = pe .* inflationFactor;
            AbsoluteError = ae .* inflationFactor;

            MSD = mean(PredictionError);
            MAE = mean(AbsoluteError);

            nBins = 10;
            ECE = self.CalculateECE(PredictedAccuracy, Accuracy, nBins);

            clipT = table(Accuracy, PredictedAccuracy, PredictionError, ...
                AbsoluteError);

            summaryS = struct;
            summaryS.ECE = ECE;
            summaryS.MSD = MSD;
            summaryS.AMSD = abs(MSD);
            summaryS.MAE = MAE;
        end

        function [s, clipT] = ReviewEfficiencyMetric(self, clipT)
            OptimalReview = SimulatePropReviewVsAccuracy(clipT, 'Optimal');
            ConfidenceReview = SimulatePropReviewVsAccuracy(clipT, 'Confidence');
            RandomReview = SimulatePropReviewVsAccuracy(clipT, 'Random');

            s = struct;
            [s.OptimalIORandom, OptimalIORandom] = CalculateAreaBetweenCurves(OptimalReview, RandomReview);
            [s.ConfidenceIORandom, ConfidenceIORandom] = CalculateAreaBetweenCurves(ConfidenceReview, RandomReview);

            s.ReviewEfficiency = s.ConfidenceIORandom / s.OptimalIORandom;

            ProportionReviewed = OptimalIORandom.PropReviewed;
            OptimalIORandom = OptimalIORandom.IOR;
            ConfidenceIORandom = ConfidenceIORandom.IOR;
            clipT = table(ProportionReviewed, OptimalIORandom, ConfidenceIORandom);
        end

        function clipT = ScoreSequencesMaxSoftmax(self, seqT)
            


            mbSize = self.ConfigFile.GetParams('PredictionMiniBatchSize');

            features = TransposeCellArrayElements(seqT.Features);
            [~, scores] = classify(self.Network, features, 'MiniBatchSize', mbSize);
            scores = TransposeCellArrayElements(scores);

            for i = 1:size(seqT, 1)
                currAnnot = seqT.Annotations{i};
                if any(strcmp(currAnnot.Properties.VariableNames, 'Score'))
                    seqT.Annotations{i} = removevars(currAnnot, 'Score');
                end

                currScores = scores{i};
                currScores = double(max(currScores, [], 2));
                seqT.Annotations{i} = addvars(seqT.Annotations{i}, currScores, 'NewVariableNames', 'Score');
            end

            clipT = CollapseSequencesIntoClips(seqT);

%             clipT = self.MaxScoreClipT(clipT);
        end

        function temp = TrainTemperatureScaler(self, seqT)
            [logits, labelArray] = self.GetLogitsLabelArray(seqT);
            options = optimset('TolX', 1e-5);
            f = @(x)CalcLoss(x, logits, labelArray);
            [temp, ~] = fminbnd(f, -1000, 1000, options);
        end

        function [logits, labelArray] = GetLogitsLabelArray(self, seqT)
            features = TransposeCellArrayElements(seqT.Features);

            mbSize = self.ConfigFile.GetParams('PredictionMiniBatchSize');
            act = activations(self.Network, features, 'FC', 'MiniBatchSize', mbSize);
            act = TransposeCellArrayElements(act);
            
            labels = GetLabelsFromTable(seqT);
            for i = 1:length(act)
                nLabels = length(labels{i});
                act{i} = act{i}(1:nLabels,:);
            end
            
            logits = vertcat(act{:});
            labels = GetLabelsFromTable(seqT);
            labels = vertcat(labels{:});
            cats = categories(labels);
            
            labelArray = zeros(size(labels,1), length(cats));
            for i = 1:length(cats)
                currCat = cats(i);
                isCurrCat = labels == currCat;
                labelArray(isCurrCat, i) = 1;
            end
            
            logits = dlarray(logits, 'BC');
        end


        function clipT = ScoreSequencesTemperatureScaling(self, seqT)
            temp = self.Temperature;
            features = TransposeCellArrayElements(seqT.Features);
            act = activations(self.Network, features, 'FC');
            act = TransposeCellArrayElements(act);

            labels = GetLabelsFromTable(seqT);
            for i = 1:length(act)
                nLabels = length(labels{i});
                currAct = act{i}(1:nLabels,:);
                act{i} = dlarray(currAct, 'BC');
            end

            scores = cell(length(act), 1);
            for i = 1:length(act)
                currPred = PredictWithTemp(temp, act{i});
                scores{i} = extractdata(currPred);
            end
            scores = TransposeCellArrayElements(scores);

            for i = 1:size(seqT, 1)
                currAnnot = seqT.Annotations{i};
                if any(strcmp(currAnnot.Properties.VariableNames, 'Score'))
                    seqT.Annotations{i} = removevars(currAnnot, 'Score');
                end

                currScores = scores{i};
                currScores = double(max(currScores, [], 2));
                seqT.Annotations{i} = addvars(seqT.Annotations{i}, currScores, 'NewVariableNames', 'Score');
            end

            clipT = CollapseSequencesIntoClips(seqT);
        end
    end

    methods(Static)
        function ECE = CalculateECE(predAcc, actAcc, nBins)
            edges = linspace(0, 1, nBins + 1);
            [~, ~, binIdx] = histcounts(predAcc, edges);

            avgAccBin = nan(nBins, 1);
            avgScoreBin = nan(nBins, 1);

            nInBin = zeros(nBins, 1);
            for i = 1:nBins
                currInBin = binIdx == i;
                nInBin(i) = sum(currInBin);

                if sum(currInBin) > 0
                    avgAccBin(i) = mean(actAcc(currInBin));
                    avgScoreBin(i) = mean(predAcc(currInBin));
                end
            end

            ECEs = nan(nBins,1);
            for i = 1:nBins
                diff = abs(avgAccBin(i) - avgScoreBin(i));
                prop = nInBin(i) / sum(nInBin);
                ECEs(i) = diff * prop;
            end
            ECE = sum(ECEs, 'omitnan');
        end

        function clipT = MaxScoreClipT(clipT)
            maxScore = cell(size(clipT.Scores, 1), 1);
            for i = 1:size(clipT.Scores, 1)
                currScores = clipT.Scores{i};
                maxScore{i} = max(currScores, [], 2);
            end

            clipT.Scores = maxScore;
        end
    end
end

function [improvArea, improvT] = CalculateAreaBetweenCurves(topCurve, bottomCurve)
IOR = nan(size(topCurve, 1), 1);

PropReviewed = nan(size(topCurve, 1), 1);
for i = 1:size(topCurve, 1)
    IOR(i) = topCurve.Accuracy(i) - bottomCurve.Accuracy(i);
    PropReviewed(i) = mean([topCurve.PropReviewed(i) bottomCurve.PropReviewed(i)]);
end
improvT = table(PropReviewed, IOR);

improvArea = IOR ./ length(IOR);
improvArea = sum(improvArea);
end

function outT = SimulatePropReviewVsAccuracy(clipT, sortMethod)
% sortMethod - Optimal, Confidence, Random
clipLengths = [];
for i = 1:size(clipT, 1)
    clipLengths = [clipLengths; size(clipT.Annotations{i}, 1)];
end
clipAccuracy = clipT.Accuracy;

if strcmpi(sortMethod, 'Optimal')
    clipT = sortrows(clipT, 'Accuracy');
elseif strcmpi(sortMethod, 'Confidence')
    clipT = sortrows(clipT, 'Score');
elseif strcmpi(sortMethod, 'Random')
    PropReviewed = linspace(0, 1, size(clipT, 1)+1)';
    startAcc = GetWeightedAccuracy(clipAccuracy, clipLengths);
    Accuracy = linspace(startAcc, 1, size(clipT, 1)+1)';
    outT = table(PropReviewed, Accuracy);
    return
end

clipAccuracy = clipT.Accuracy;
totalLen = sum(clipLengths);

PropReviewed = zeros(length(clipAccuracy)+1, 1);
Accuracy = zeros(length(clipAccuracy)+1, 1);
for i = 0:length(clipAccuracy)
    if i ~= 0
        clipAccuracy(i) = 1;
    end

    currAvgAcc = GetWeightedAccuracy(clipAccuracy, clipLengths);

    if i ~= 0
        PropReviewed(i+1) = sum(clipLengths(1:i))/totalLen;
    end

    Accuracy(i+1) = currAvgAcc;
end

outT = table(PropReviewed, Accuracy);
end

function weightedAccuracy = GetWeightedAccuracy(clipScores, clipLengths)
inflationFactor = clipLengths / mean(clipLengths);
clipScores = clipScores .* inflationFactor;
weightedAccuracy = mean(clipScores);
end

function clipT = CalculateAverageClipScore(clipT)
acc = nan(size(clipT, 1), 1);
score = nan(size(clipT, 1), 1);

for i = 1:size(clipT,1)

    type = clipT.Annotations{i}.Type;
    labels = clipT.Annotations{i}.Label;
    preds = clipT.Annotations{i}.Prediction;
    currScores = clipT.Annotations{i}.Score;
    
    notAnnot = type == categorical({'C'}) | ...
               type == categorical({'UL'});
    
    labels = labels(~notAnnot);
    preds = preds(~notAnnot);
    
    if ~isempty(labels)
        acc(i) = mean(labels == preds);
    end
    
    score(i) = mean(currScores);
end

if any(strcmp('Accuracy', clipT.Properties.VariableNames))
    clipT = removevars(clipT, 'Accuracy');
end


if any(strcmp('Score', clipT.Properties.VariableNames))
    clipT = removevars(clipT, 'Score');
end
clipT = addvars(clipT, acc, score, 'NewVariableNames', {'Accuracy', 'Score'});

% 
% Accuracy = nan(size(clipT, 1), 1);
% Score = nan(size(clipT, 1), 1);
% for i = 1:size(clipT, 1)
%     labels = GetLabelsFromTable(clipT);
%     currPredCorr = mean(labels{i} == clipT.Prediction{i});
%     Accuracy(i) = currPredCorr;
%     currScores = clipT.Scores{i};
%     avgScore = mean(currScores);
%     Score(i) = avgScore;
% end
% 
% if any(strcmp('Accuracy', clipT.Properties.VariableNames))
%     clipT = removevars(clipT, 'Accuracy');
% end
% 
% if any(strcmp('Score', clipT.Properties.VariableNames))
%     clipT = removevars(clipT, 'Score');
% end
% clipT = addvars(clipT, Accuracy, Score);
end

function loss = CalcLoss(temp, logits, target)
pred = PredictWithTemp(temp, logits);

target = dlarray(target,'BC');
loss = crossentropy(pred, target);
end

function pred = PredictWithTemp(temp, logits)
smInput = logits ./ temp;
pred = softmax(smInput);
end

function labels = GetLabelsFromTable(t)
labels = {};

for i=1:size(t, 1)
    labels = [labels; {t.Annotations{i}.Label}];
end
end

