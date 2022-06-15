function [files, exists] = GetValidFolderFiles(parentFolder, varargin)

p = inputParser;
addOptional(p, 'Contains', '');
addOptional(p, 'DoesNotContain', '');
addOptional(p, 'Extension', '');
parse(p, varargin{:});

d = dir(parentFolder);
dfolders = d(~[d(:).isdir]);

if isempty(dfolders)
    files = [];
    exists = false;
    return
end
dfolders = struct2table(dfolders, 'AsArray', true);

if ~isempty(p.Results.Contains) && ~isempty(dfolders)
    containsStr = false(size(dfolders,1),1);
    for i = 1:size(dfolders,1)
        containsStr(i) = contains(dfolders.name{i}, p.Results.Contains);
    end
    dfolders = dfolders(containsStr,:);
end


if ~isempty(p.Results.DoesNotContain) && ~isempty(dfolders)
    containsStr = false(size(dfolders,1),1);
    for i = 1:size(dfolders,1)
        containsStr(i) = ~contains(dfolders.name{i}, p.Results.DoesNotContain);
    end
    dfolders = dfolders(containsStr,:);
end


if ~isempty(p.Results.Extension) && ~isempty(dfolders)
    [~, ~, exts] = fileparts(dfolders.name);
    
    if size(exts,1) == 1
        exts = {exts};
    end
    
    hasExt = false(length(exts),1);
    for i = 1:length(exts)
        currExt = exts{i};
        hasCurrExt = strcmp(currExt, p.Results.Extension);
        hasCurrExtBare = strcmp(currExt(2:end), p.Results.Extension);

        if hasCurrExt || hasCurrExtBare
            hasExt(i) = true;
        end
    end
    dfolders = dfolders(hasExt,:);
end

if isempty(dfolders)
    files = [];
    exists = false;
    return
end

keep = true(size(dfolders,1),1);
for i = 1:size(dfolders,1)
    if strcmp(dfolders.name{i}(1), '.')
        keep(i) = false;
    end
end
exists = true;
files = dfolders(keep,:);
end
