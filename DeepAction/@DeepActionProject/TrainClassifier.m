function self = TrainClassifier(self)
self = self.TrainNetwork();
self = self.GenerateClipPredictions();
self = self.EvaluateNetwork(); 
end
