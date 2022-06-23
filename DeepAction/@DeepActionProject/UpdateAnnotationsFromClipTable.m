function UpdateAnnotationsFromClipTable(self, varargin)
if nargin == 2
    clipTable = varargin{1};
else
    clipTable = self.ClipTable;
end

uniqueVids = unique(clipTable.Video);

for i = 1:length(uniqueVids)
    isCurrVid = strcmp(clipTable.Video, uniqueVids{i});
    currVidT = clipTable(isCurrVid, :);
    currAnnotT = vertcat(currVidT.Annotations{:});

    currAnnot = Annotation(self, uniqueVids{i});
    currAnnot.UpdateAnnotations(currAnnotT)
end
end