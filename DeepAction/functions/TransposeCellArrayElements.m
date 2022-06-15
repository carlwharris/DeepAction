
function cellArray = TransposeCellArrayElements(cellArray)
for i = 1:length(cellArray)
    cellArray{i} = cellArray{i}';
end
end
