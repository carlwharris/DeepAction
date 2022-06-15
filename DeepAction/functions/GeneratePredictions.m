function clipT = GeneratePredictions(network, clipT, varargin)

mbSize = 128;
if nargin == 3
    mbSize = varargin{1};
end

seqT = SplitClipDataIntoSequences(self, clipT);
features = TransposeCellArrayElements(seqT.Features);
[pred, scores] = classify(network, features, 'MiniBatchSize', mbSize);
seqT.Predictions = TransposeCellArrayElements(pred);
seqT.Scores = TransposeCellArrayElements(scores);

clipT = CollapseSequencesIntoClips(seqT);
end