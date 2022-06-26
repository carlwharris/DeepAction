function clipT = LoadAnnotations(self, clipT)

if self.VerboseLevel > 1
    fprintf('  - Loading annotations... ')
end

clipTCollapsed = CollapseSequences(clipT);


Annotations = cell(size(clipT,1), 1);
for i = 1:size(clipTCollapsed,1)
    vidName = clipTCollapsed.Video{i};
    vidRows = clipTCollapsed.Rows{i};

    currAnnot = Annotation(self, vidName);
    currAnnot = currAnnot.Load();
    annotT = currAnnot.AnnotationTable;

    for j = 1:size(vidRows,1)
        currParentTRow = vidRows.RowNumber(j);
        
        if any(strcmp(vidRows.Properties.VariableNames, 'StartFrame'))
            currIndices = vidRows.StartFrame(j):vidRows.EndFrame(j);
        elseif any(strcmp(vidRows.Properties.VariableNames, 'AnnotatedIndices'))
            currIndices = vidRows.AnnotatedIndices{j};
        elseif any(strcmp(vidRows.Properties.VariableNames, 'UnannotatedIndices'))
            currIndices = vidRows.UnannotatedIndices{j};
        end

        Annotations{currParentTRow} = annotT(currIndices, :);
    end
end

clipT = addvars(clipT, Annotations);

if self.VerboseLevel > 1
    fprintf('complete\n')
end
end

function t = GetSingleLabelCategories(behaviorArrayT)
behaviors = behaviorArrayT.Properties.VariableNames(2:end);

cats = cell(size(behaviorArrayT,1),1);

for i = 2:size(behaviorArrayT,2)
    currBehav = [behaviorArrayT{:, i}];
    cats(currBehav == 1) = behaviors(i-1);
end

emptyIdxs = cellfun(@isempty, cats);
cats(emptyIdxs) = {'missing'};

t = categorical(cats,behaviors);
end


function clipT = CollapseSequences(clipT)
RowNumber = [1:size(clipT)]';

clipT = addvars(clipT, RowNumber);
uniqueVideos = unique(clipT.Video);

Video = {};
Rows = {};
for i = 1:length(uniqueVideos)
    currVideo = uniqueVideos{i};
    
    currVid = clipT(strcmp(clipT.Video, currVideo), :);
    
    Video = [Video; currVideo];
    Rows = [Rows; {currVid}];
end

clipT = table(Video, Rows);
end
