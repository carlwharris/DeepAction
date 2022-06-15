
function self = EvaluateConfidenceScorer(self)

confScorer = self.ConfidenceScorer;

if self.VerboseLevel > 1
    fprintf('  - %s scorer\n', confScorer.Method);
end

tmpS = struct;
tmpS.Properties.Method = confScorer.Method;

if self.VerboseLevel > 1
    fprintf('    - Training set\n');
end
isSet = self.ClipTable.Set == categorical({'Train'});
[summaryS, calClipT,revClipT] = EvaluateScorer(confScorer, self.ClipTable(isSet, :));
tmpS.Summary.Train = summaryS;
tmpS.Calibration.Train = calClipT;
tmpS.Review.Train = revClipT;

if self.VerboseLevel > 1
    fprintf('    - Test set\n');
end
isSet = self.ClipTable.Set == categorical({'Test'});
[summaryS, calClipT,revClipT] = EvaluateScorer(confScorer, self.ClipTable(isSet, :));
tmpS.Summary.Test = summaryS;
tmpS.Calibration.Test = calClipT;
tmpS.Review.Test = revClipT;

self.Results.ConfidenceScorer = tmpS;

% Save summary to CSV
csvPath = fullfile(self.ProjectPath, 'results', 'confidence_score.xlsx');
trainT = struct2table(self.Results.ConfidenceScorer.Summary.Train, 'AsArray', true);
testT = struct2table(self.Results.ConfidenceScorer.Summary.Test, 'AsArray', true);
Set = [{'Train'}; {'Test'}];
summaryT = [table(Set), [trainT; testT]];

summaryT = removevars(summaryT, {'ECE', 'AMSD', 'OptimalIORandom', 'ConfidenceIORandom'});
writetable(summaryT, csvPath, 'WriteMode', 'replacefile');

fprintf('\n')
FormatTable(summaryT, 'Title', 'Confidence score performance', 'PrintOutput', true);

end