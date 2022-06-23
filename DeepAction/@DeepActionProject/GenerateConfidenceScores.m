function self = GenerateConfidenceScores(self)
self = self.TrainConfidenceScorer();
self.ClipTable = self.ConfidenceScorer.GenerateClipScores(self.ClipTable);
self = self.EvaluateConfidenceScorer();
end