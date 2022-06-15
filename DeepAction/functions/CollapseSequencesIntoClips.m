
function clipT = CollapseSequencesIntoClips(seqT)
clipNos = unique(seqT.ClipNumber);

clipT = table;
for i = 1:length(clipNos)
    currClipNo = clipNos(i);
    currSeqT = seqT(seqT.ClipNumber == currClipNo,:);
    
    varNames = currSeqT.Properties.VariableNames;
    
    currClipT = table;
    for j = 1:length(varNames)
        currColVals = currSeqT.(varNames{j});
        if iscell(currColVals)
            if size(currColVals{1}, 1) > 1
                currClipT.(varNames{j}) = {vertcat(currColVals{:})};
            else
                currClipT.(varNames{j}) = {currColVals{1}};
            end
        else
            currClipT.(varNames{j}) = currColVals(1);
        end
    end
    

    if strcmp('Indices', currClipT.Properties.VariableNames)
        indices = currClipT.Indices{1};
    else
        indices = currClipT.StartFrame(1):currClipT.EndFrame(1);
    end

    [~, order] = sort(indices);
    
    for j = 1:length(varNames)
        currColVals = currClipT.(varNames{j});
        if iscell(currColVals)
            if size(currColVals{1}, 1) > 1
                currVar = currClipT.(varNames{j}){1};
                currVar = currVar(order, :);
                currClipT.(varNames{j}) = {currVar};
            end
        end
    end
    
    clipT = [clipT; currClipT];
end

end