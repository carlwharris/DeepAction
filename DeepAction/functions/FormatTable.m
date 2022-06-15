
function fileLines = FormatTable(t, varargin)

p = inputParser;
p.KeepUnmatched=true;

addOptional(p, 'Title', []);
addOptional(p, 'PrintOutput', false);
parse(p,varargin{:});


varNames = t.Properties.VariableNames;
tableColumns = cell(size(t, 1)+3, length(varNames));
for i = 1:length(varNames)
    currColText = FormatColumn(t(:, i));
    tableColumns(:, i) = currColText;
end

hasRowNames = ~isempty(t.Properties.RowNames);
if hasRowNames
    tmp = table(t.Properties.RowNames, 'VariableNames', {' '});
    colText = FormatColumn(tmp);
    tableColumns = [colText tableColumns];
end

fileLines = {};

for i = 1:size(tableColumns, 1)
    newFileLines = strjoin([{''}, tableColumns(i, :), {''}], ' | ');

    if ~isempty(p.Results.Title) && (i == 1)
        nSpaces = round(length(newFileLines)/2) - round(length(p.Results.Title)/2);
        spaces = repmat(' ', 1, nSpaces);

        fileLines = [fileLines; sprintf('%s%s', spaces, p.Results.Title)];
        dashes = repmat('=', 1, length(newFileLines));
        dashes(1) = ' ';
        dashes(end) = ' ';
        fileLines = [fileLines; sprintf('%s', dashes)];%; sprintf('%s', repmat(' ', 1, length(newFileLines)))];

    end

    if i == 2 || i == size(tableColumns, 1)
        newFileLines = strjoin([{''}, tableColumns(i, :), {''}], '-+-');
        newFileLines(1) = ' ';
        newFileLines(end) = ' ';
%         newFileLines{}
    end
    

    fileLines = [fileLines; newFileLines];

end

if p.Results.PrintOutput
    fprintf('%s', strjoin(fileLines, '\n'))
    fprintf('\n')
end

end

function colText = FormatColumn(currCol)

txtLengths = [];

varName = currCol.Properties.VariableNames{1};
currTxt = sprintf('%s', varName);
txtLengths = [txtLengths; length(currTxt)];

if iscell(currCol{1, 1})
    for i = 1:size(currCol, 1)
        currTxt = sprintf('%s', currCol{i, 1}{1});
        txtLengths = [txtLengths; length(currTxt)];
    end
else
    isWholeNums = all(rem(currCol{:,1}, 1) == 0);

    for i = 1:size(currCol, 1)

        if isWholeNums
            currTxt = sprintf('%d', currCol{i, 1});
        else
            currTxt = sprintf('%0.3f', currCol{i, 1});
        end
        
        txtLengths = [txtLengths; length(currTxt)];
    end
end

colWidth = max(txtLengths);

colText = {};
nSpaces = colWidth - txtLengths(1);
spacesTxt = repmat(' ', 1, nSpaces);
currTxt = sprintf('%s%s', varName, spacesTxt);
colText = [colText; {currTxt}];

dashes = repmat('-', 1, colWidth);
currTxt = sprintf('%s', dashes);
colText = [colText; {currTxt}];

txtLengths(1) = [];
if iscell(currCol{1, 1})
    for i = 1:size(currCol, 1)
        nSpaces = colWidth - txtLengths(i);
        spacesTxt = repmat(' ', 1, nSpaces);
        currTxt = sprintf('%s%s', currCol{i, 1}{1}, spacesTxt);
        colText = [colText; {currTxt}];
    end
else
    for i = 1:size(currCol, 1)
        nSpaces = colWidth - txtLengths(i);
        spacesTxt = repmat(' ', 1, nSpaces);

        if isWholeNums
            currTxt = sprintf('%d%s', currCol{i, 1}, spacesTxt);
        else
            currTxt = sprintf('%0.3f%s', currCol{i, 1}, spacesTxt);
        end

%         currTxt = sprintf('%s%s', currCol{i, 1}{1}, spacesTxt);
        colText = [colText; {currTxt}];
    end
end


dashes = repmat('-', 1, colWidth);
currTxt = sprintf('%s', dashes);
colText = [colText; {currTxt}];
end