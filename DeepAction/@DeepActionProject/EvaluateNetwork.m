function self = EvaluateNetwork(self)


verboseLevl = self.VerboseLevel;
if verboseLevl > 0
    fprintf('Evaluating network...\n')
end

summaryT = table(zeros(3, 1), zeros(3, 1), ...
    'VariableNames', {'Accuracy', 'F1'}, ...
    'RowNames', {'Train', 'Validate', 'Test'});

classScoresS = struct;

% TRAIN
if verboseLevl > 0
    fprintf('  - Generating train set predictions \n')
end

isSet = self.ClipTable.Set == categorical({'Train'});
[avgPerf, classPerf] = self.ScoreClips(self.ClipTable(isSet, :));
summaryT(1, :) = avgPerf;
classScoresS.Train = classPerf;

% VALIDATE
if verboseLevl > 0
    fprintf('  - Generating validation set predictions \n')
end

isSet = self.ClipTable.Set == categorical({'Validate'});
[avgPerf, classPerf] = self.ScoreClips(self.ClipTable(isSet, :));

summaryT(2, :) = avgPerf;
classScoresS.Validate = classPerf;

% TEST
if verboseLevl > 0
    fprintf('  - Generating test set predictions \n')
end
isSet = self.ClipTable.Set == categorical({'Test'});
[avgPerf, classPerf] = self.ScoreClips(self.ClipTable(isSet, :));

summaryT(3, :) = avgPerf;
classScoresS.Test = classPerf;

self.Results.Classifier.Summary = summaryT;

% CSV files
resFolder = fullfile(self.ProjectPath, 'results');
if ~isfolder(resFolder)
    mkdir(resFolder);
end

csvPath = fullfile(resFolder, 'classifier_performance.xlsx');
writetable(summaryT, csvPath, 'Sheet', 'summary', 'WriteRowNames', true); %'WriteMode', 'append"'

self.Results.Classifier.ClassScores = classScoresS;
writetable(classScoresS.Train, csvPath, 'Sheet', 'train', 'WriteRowNames', true, 'WriteMode', 'overwritesheet');
writetable(classScoresS.Validate, csvPath, 'Sheet', 'validate', 'WriteRowNames', true, 'WriteMode', 'overwritesheet');
writetable(classScoresS.Test, csvPath, 'Sheet', 'test', 'WriteRowNames', true, 'WriteMode', 'overwritesheet');


% Confusion matrices
CreateSaveConfusionMatrix(self.ClipTable, 'Train', resFolder);
CreateSaveConfusionMatrix(self.ClipTable, 'Validate', resFolder);
CreateSaveConfusionMatrix(self.ClipTable, 'Test', resFolder);


% DISPLAY OUTPUT
if verboseLevl > 0
    fprintf('\n')
    title = 'Overall performance';
    FormatTable(self.Results.Classifier.Summary, 'Title', title, 'PrintOutput', true);
    
    fprintf('\n')

    title = 'Behavior results (test set)';
    FormatTable(classScoresS.Test, 'Title', title, 'PrintOutput', true);
end

end

function CreateSaveConfusionMatrix(clipT, set, parentFolder)
isSet = clipT.Set == categorical({set});
allAnnots = vertcat(clipT(isSet, :).Annotations{:});
trueLabels = removecats(allAnnots.Label);
predLabels = removecats(allAnnots.Prediction);
trueLabels = reordercats(trueLabels);
predLabels = reordercats(predLabels);

f = figure('outerposition', [0 0 600 600], 'visible','off');
axis square
h = subplot(1, 1, 1);
h = CreateConfusionMatrix(h, trueLabels, predLabels);
title(h, [set, ' confusion matrix'])

path = fullfile(parentFolder, [lower(set), '_CM.png']);
saveas(f, path)
close(f)
% 
% f = figure('visible','off');
% axis square
% plotconfusion(trueLabels, predLabels)
% f.Position = [0, 0, 500, 500];
% path = fullfile(parentFolder, [lower(set), '_full_CM.png']);
% saveas(f, path)
% close(f)
end

function h = CreateConfusionMatrix(h, trueLabels, predLabels)

cats = categories(trueLabels);
% [~, I] = sort(countcats(trueLabels), 'descend');
% cats = cats(I);
matrix = confusionmat(trueLabels, predLabels, 'Order', cats);
props = zeros(size(matrix));

for i = 1:size(props,1)
    props(i, :) = matrix(i,:) ./ sum(matrix(i,:));
end

x = linspace(1, length(cats)+1, length(cats)+1);
y = linspace(length(cats)+1, 1, length(cats)+1);

props = [props; zeros(1, size(props, 1))];
props = [props zeros(size(props, 1), 1)];

pcolor(h, x, y, props);

yticks(1.5:length(cats)+1)
xticks(1.5:length(cats)+1)

yticklabels(cats(end:-1:1));
xticklabels(cats);

nTicks = size(get(h,'colormap'),1);

if nTicks > 10
    nTicks = 10;
end

hT = (0:nTicks-1)' / (nTicks-1) / 3;
map = hsv2rgb([hT repmat(.5, nTicks, 1) repmat(.9, nTicks, 1)]);
colormap(map)

% b = colorbar;
% 
% if sum(matrix(matrix > 1)) > 0
%     ylabel(b, 'Observation counts')
% else
%     ylabel(b, 'Row-normalized probability')
% end

cellFS = 14;
xlabel(h, 'Predicted class')
ylabel(h, 'True class')

midX = 1.5:length(cats)+0.5;
midY = length(cats)+0.5:-1:1.5;
for i = 1:length(midX)
    for j = 1:length(midY)
        if props(j, i) ~= 0
            if props(j, i) <= 1
                currStr = sprintf('%1.2f', props(j, i));
                text(midX(i), midY(j), currStr, 'HorizontalAlignment', 'center', 'FontSize', cellFS);
            else
                currStr = sprintf('%d', props(j, i));
                text(midX(i), midY(j), currStr, 'HorizontalAlignment', 'center', 'FontSize', cellFS);
            end
        end
    end
end
set(h, 'FontSize', 16);
h.Children(end).EdgeAlpha = 0.25;
h.LineWidth = 3;
h.TickDir = 'none';

end



