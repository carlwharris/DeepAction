
function project = MarkClipsAsIncomplete(project, numberToMark)
nRows = size(project.ClipTable,1);
randIdxs = randperm(nRows);
selRowNums = randIdxs(1:numberToMark);

project.ClipTable.Type(selRowNums) = categorical({'UR'});
end