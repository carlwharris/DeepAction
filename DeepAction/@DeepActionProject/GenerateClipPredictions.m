function self = GenerateClipPredictions(self)
% Generate predicted labels for each clip

if self.VerboseLevel > 0
    fprintf('Generating clip predictions... ')
end

mbSize = self.ConfigFile.GetParams('PredictionMiniBatchSize');

seqT = SplitClipDataIntoSequences(self, self.ClipTable);
features = TransposeCellArrayElements(seqT.Features);
predictions = classify(self.Network, features, 'MiniBatchSize', mbSize);
predictions = TransposeCellArrayElements(predictions);

isRev = seqT.Type == categorical({'R'});
for i = 1:size(seqT, 1)
    if any(strcmp('Prediction', seqT.Annotations{i}.Properties.VariableNames))
        seqT.Annotations{i} = removevars(seqT.Annotations{i}, 'Prediction');
    end
    currPredictions = predictions{i};
    seqT.Annotations{i}.Prediction = currPredictions;

    if isRev(i)
        continue
    end

    notAnnot = seqT.Annotations{i}.Type == categorical({'C'}) | ...
               seqT.Annotations{i}.Type == categorical({'UL'});

    seqT.Annotations{i}.Label(notAnnot) = currPredictions(notAnnot);
    seqT.Annotations{i}.Type(notAnnot) = categorical({'C'});
end

self.ClipTable = CollapseSequencesIntoClips(seqT);
if self.VerboseLevel > 0
    fprintf('complete\n')
end

end