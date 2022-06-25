function AddFileAnnotations(self, annotFilePath, overwrite)
% Add annotations contained in 'annotFilePath' to annotations
% table

self = Load(self);

if isempty(self.AnnotationTable)
    return
end

fileAnnots = readtable(annotFilePath);
annotT = self.AnnotationTable;

if overwrite
    labelsStr = repmat({'UL'}, size(annotT,1), 1);
    annotT.Label = categorical(labelsStr, {'UL'});
end

annotTVarNames = fileAnnots.Properties.VariableNames;
annotTBehaviors = annotTVarNames(~strcmp('Frame', annotTVarNames));

annotT.Label = addcats(annotT.Label, annotTBehaviors);
for i = 1:length(annotTBehaviors)
    currLabel = annotTBehaviors{i};
    frameIdxs = fileAnnots.Frame(fileAnnots.(currLabel) == 1);

    annotT.Label(frameIdxs) = categorical({currLabel});
    annotT.Type(frameIdxs) = categorical({'I'});
end

self.AnnotationTable = annotT;
self.Save()
end