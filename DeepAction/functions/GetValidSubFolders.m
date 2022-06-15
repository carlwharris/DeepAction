function folders = GetValidSubFolders(parentFolder, varargin)
p = inputParser;
addOptional(p, 'Contains', '');
addOptional(p, 'DoesNotContain', '');
parse(p, varargin{:});


d = dir(parentFolder);
dfolders = d([d(:).isdir]);
dfolders = dfolders(~ismember({dfolders(:).name},{'.','..'}));

if isempty(dfolders)
    folders = [];
    return
end
folders = struct2table(dfolders, 'AsArray', true);

if ~isempty(p.Results.Contains) && ~isempty(folders)
    containsStr = false(size(folders,1),1);
    for i = 1:size(folders,1)
        containsStr(i) = contains(folders.name{i}, p.Results.Contains);
    end
    folders = folders(containsStr,:);
end

if ~isempty(p.Results.DoesNotContain) && ~isempty(folders)
    containsStr = false(size(folders,1),1);
    for i = 1:size(folders,1)
        containsStr(i) = ~contains(folders.name{i}, p.Results.Contains);
    end
    folders = folders(containsStr,:);
end

if isempty(dfolders)
    folders = [];
    return
end

end