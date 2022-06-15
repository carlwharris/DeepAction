function [summaryS, calClipT, revClipT] = EvaluateScorer(self, clipT)
% clipT = GenerateClipScores(self, clipT);
[summaryS, calClipT] = EvaluateCalibration(self, clipT);
[revSummaryS, revClipT] = ReviewEfficiencyMetric(self, clipT);

summaryS = MergeStructs(summaryS, revSummaryS);
end
 