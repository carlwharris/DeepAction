

projectFolder = '/Users/harriscaw/Documents/Behavior classification/Projects/JuangDemo';
project = DeepActionProject(projectFolder);
% project.CreateProject()

demoDataFolder = '/Users/harriscaw/Documents/Behavior classification/DeepAction datasets/demo_data'
demoVideoFolder = fullfile(demoDataFolder, 'videos');
demoVideoFiles = GetValidFolderFiles(demoVideoFolder);
[~, videoNames, ~] = fileparts(demoVideoFiles.name);
paths = fullfile(demoVideoFiles.folder, demoVideoFiles.name);
% videoImportT = table(videoNames, paths, 'VariableNames',{'VideoName', 'VideoPath'});
videoImportT = table(videoNames, demoVideoFiles.name, 'VariableNames',{'VideoName', 'VideoPath'});
disp(videoImportT)

videoImportT.Properties.RowNames = {'A', 'B', 'C', 'D', 'E', 'F'}

%%

t = videoImportT;

nums = [1:6]';
t = addvars(t, nums)
varNames = t.Properties.VariableNames;

tmp = table(t.Properties.RowNames, 'VariableNames', {' '})

FormatTable(t, 'PrintOutput', false)

title = 'testTableToFile'
path = fullfile(pwd, 'testTableToFile');


FormatTableToTxtFile(t, path, 'Title', title, 'Append', true)


% 
% function FormatTableToTxtFile(t, path, varargin)
% % Write table t to file path
% 
% formatted = FormatTable(t, varargin{:});
% formattedJoined = strjoin(formatted, '\n');
% [~, ~, ext] = fileparts(path);
% 
% if isempty(ext)
%     path = [path, '.txt'];
% end
% 
% fid = fopen(path, 'w');
% fwrite(fid, formattedJoined);
% fclose(fid);
% end
% 
% function fileLines = FormatTable(t, varargin)
% 
% p = inputParser;
% addOptional(p, 'Title', []);
% addOptional(p, 'PrintOutput', true);
% parse(p,varargin{:});
% 
% 
% varNames = t.Properties.VariableNames;
% tableColumns = cell(size(t, 1)+2, length(varNames));
% for i = 1:length(varNames)
%     currColText = FormatColumn(t(:, i));
%     tableColumns(:, i) = currColText;
% end
% 
% hasRowNames = ~isempty(t.Properties.RowNames);
% if hasRowNames
%     tmp = table(t.Properties.RowNames, 'VariableNames', {' '});
%     colText = FormatColumn(tmp);
%     tableColumns = [colText tableColumns];
% end
% 
% fileLines = {};
% 
% for i = 1:size(tableColumns, 1)
%     newFileLines = strjoin(tableColumns(i, :), ' | ');
% 
%     if ~isempty(p.Results.Title) && (i == 1)
%         nSpaces = round(length(newFileLines)/2) - round(length(p.Results.Title)/2);
%         spaces = repmat(' ', 1, nSpaces);
% 
%         fileLines = [fileLines; sprintf('%s%s', spaces, p.Results.Title)];
%         dashes = repmat('-', 1, length(newFileLines));
%         fileLines = [fileLines; sprintf('%s', dashes); sprintf('%s', repmat(' ', 1, length(newFileLines)))];
% 
%     end
% 
%     
%     fileLines = [fileLines; newFileLines];
% end
% 
% if p.Results.PrintOutput
%     fprintf('%s', strjoin(fileLines, '\n'))
%     fprintf('\n')
% end
% 
% end
% 
% function colText = FormatColumn(currCol)
% 
% txtLengths = [];
% 
% varName = currCol.Properties.VariableNames{1};
% currTxt = sprintf('%s', varName);
% txtLengths = [txtLengths; length(currTxt)];
% 
% if iscell(currCol{1, 1})
%     for i = 1:size(currCol, 1)
%         currTxt = sprintf('%s', currCol{i, 1}{1});
%         txtLengths = [txtLengths; length(currTxt)];
%     end
% else
%     isWholeNums = all(rem(currCol{:,1}, 1) == 0);
% 
%     for i = 1:size(currCol, 1)
% 
%         if isWholeNums
%             currTxt = sprintf('%d', currCol{i, 1});
%         else
%             currTxt = sprintf('%0.3f', currCol{i, 1});
%         end
%         
%         txtLengths = [txtLengths; length(currTxt)];
%     end
% end
% 
% colWidth = max(txtLengths);
% 
% colText = {};
% nSpaces = colWidth - txtLengths(1);
% spacesTxt = repmat(' ', 1, nSpaces);
% currTxt = sprintf('%s%s', varName, spacesTxt);
% colText = [colText; {currTxt}];
% 
% dashes = repmat('-', 1, colWidth);
% currTxt = sprintf('%s', dashes);
% colText = [colText; {currTxt}];
% 
% txtLengths(1) = [];
% if iscell(currCol{1, 1})
%     for i = 1:size(currCol, 1)
%         nSpaces = colWidth - txtLengths(i);
%         spacesTxt = repmat(' ', 1, nSpaces);
%         currTxt = sprintf('%s%s', currCol{i, 1}{1}, spacesTxt);
%         colText = [colText; {currTxt}];
%     end
% else
%     for i = 1:size(currCol, 1)
%         nSpaces = colWidth - txtLengths(i);
%         spacesTxt = repmat(' ', 1, nSpaces);
% 
%         if isWholeNums
%             currTxt = sprintf('%d%s', currCol{i, 1}, spacesTxt);
%         else
%             currTxt = sprintf('%0.3f%s', currCol{i, 1}, spacesTxt);
%         end
% 
% %         currTxt = sprintf('%s%s', currCol{i, 1}{1}, spacesTxt);
%         colText = [colText; {currTxt}];
%     end
% end
% 
% end