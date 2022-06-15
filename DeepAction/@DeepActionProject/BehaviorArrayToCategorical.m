function annotT = BehaviorArrayToCategorical(annotT)

% If input is a single array
if any(strcmpi('Frame', annotT.Properties.VariableNames))
    annotT = SingleArrayToCategorical(annotT);

% If input is a table of clips    
else
    initCatBehav = cell(size(annotT, 1), 1);
    if any(strcmp('Labels', annotT.Properties.VariableNames))
        annotT = removevars(annotT, 'Labels');
    end

    annotT = addvars(annotT, initCatBehav, 'NewVariableNames', 'Labels');
    for i = 1:size(annotT, 1)
        behavCats = SingleArrayToCategorical(annotT.Annotations{i});
        annotT.Labels{i} = behavCats;
    end
end
end


function behavCats = SingleArrayToCategorical(behaviorArray)
notBehaviorNames = {'Frame', 'TimeStamp', 'Type'};

varNames = behaviorArray.Properties.VariableNames;
behaviorLabelIdxs = find(~ismember(varNames, notBehaviorNames));
behaviorLabels = varNames(behaviorLabelIdxs);

behaviorOnlyArray = behaviorArray{:, behaviorLabelIdxs};

behavCats = cell(size(behaviorOnlyArray, 1), 1);
for i = 1:size(behaviorOnlyArray, 1)
    idx = find(behaviorOnlyArray(i, :) == 1);
    
    if ~isempty(idx)
        behavCats{i} = behaviorLabels{idx};
    else
        behavCats{i} = 'UL';
    end
end

% disp(behavCats)
behavCats = categorical(behavCats, behaviorLabels);
end
