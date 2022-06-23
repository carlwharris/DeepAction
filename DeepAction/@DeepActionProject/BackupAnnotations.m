function BackupAnnotations(self)
t = now;
d = datetime(t,'ConvertFrom','datenum');

d.Format = 'yyyy-MM-dd_HH-mm-ss';
backup_folder = fullfile(self.ProjectPath, 'annotations_backup', char(d));

mkdir(backup_folder)

if self.VerboseLevel > 1
    fprintf('Backing up annotations to ./annotations_backup/%s... ', char(d))
end

copyfile(fullfile(self.ProjectPath, 'annotations'), backup_folder)

if self.VerboseLevel > 1
    fprintf('complete\n')
end
end