function SaveClassifier(self)
if isempty(self.Network)
    fprintf('No classifier has been trained!');
    return
end

t = now;
d = datetime(t,'ConvertFrom','datenum');

d.Format = 'yyyy-MM-dd_HH-mm-ss';
destFolder = fullfile(self.ProjectPath, 'classifiers', char(d));

mkdir(destFolder)

if self.VerboseLevel > 1
    fprintf('Saving classifier to ./classifiers/%s... ', char(d))
end

Network = self.Network;
save(fullfile(destFolder, 'Network.mat'), 'Network');

if self.VerboseLevel > 1
    fprintf('complete\n')
end
end