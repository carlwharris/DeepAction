function self = TrainConfidenceScorer(self)

method = self.ConfigFile.GetParams('ScoringMethod');

confScorer = ConfidenceScorer(self, method);

if strcmp(method, 'TemperatureScaling')
    isSet = self.ClipTable.Set == categorical({'Validate'});
    confScorer = TrainConfidenceScorer(confScorer, self.ClipTable(isSet, :));
else
    isSet = self.ClipTable.Set == categorical({'Train'});
    confScorer = TrainConfidenceScorer(confScorer, self.ClipTable(isSet, :));
end
self.ConfidenceScorer = confScorer;
end