function [GlobalScores, ClassScores]  = ScoreClips(clipT)


% groundTruthLabels = vertcat(clipT.Prediction{:});

groundTruthLabels = [];
methodLabels = [];
for i=1:size(clipT, 1)
    groundTruthLabels = [groundTruthLabels; clipT.Annotations{i}.Label];
    methodLabels = [methodLabels; clipT.Annotations{i}.Prediction];
end

catsStr = categories(groundTruthLabels);
catsStr = catsStr(~strcmpi('UL', catsStr));

cats = categorical(catsStr);

Precision = zeros(length(cats), 1);
Recall = zeros(length(cats), 1);
F1 = zeros(length(cats), 1);
TruePositiveRate = zeros(length(cats), 1);
FalsePositiveRate = zeros(length(cats), 1);
for i = 1:length(cats)
    currCat = cats(i);
    TP = groundTruthLabels == currCat & methodLabels == currCat;
    TP = sum(TP);
    
    FP = groundTruthLabels ~= currCat & methodLabels == currCat;
    FP = sum(FP);
    
    FN = groundTruthLabels == currCat & methodLabels ~= currCat;
    FN = sum(FN);
    
    TN = groundTruthLabels ~= currCat & methodLabels ~= currCat;
    TN = sum(TN);
    
    currPrecision = TP / (TP + FP);
    currRecall = TP / (TP + FN);
    currF1 = 2 .* ((currPrecision .* currRecall) / (currPrecision + currRecall));
    currTPR = TP / (TP + FN);
    currFPR = FP / (FP + TN);
    
    Precision(i) = currPrecision;
    Recall(i) = currRecall;
    TruePositiveRate(i) = currTPR;
    FalsePositiveRate(i) = currFPR;
    F1(i) = currF1;    
end

ClassScores = table(Precision, Recall, TruePositiveRate, FalsePositiveRate, F1, 'RowNames', catsStr);

F1(isnan(F1)) = 0;
F1 = mean(F1);
TP = groundTruthLabels == methodLabels;
TP = sum(TP);
Accuracy = TP / length(groundTruthLabels);

GlobalScores = table(Accuracy, F1);
end

