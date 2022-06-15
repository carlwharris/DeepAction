
function FormatTableToTxtFile(t, path, varargin)
% Write table t to file path


p = inputParser;
p.KeepUnmatched=true;

addOptional(p, 'Append', false);
parse(p,varargin{:});


formatted = FormatTable(t, varargin{:});
formattedJoined = strjoin(formatted, '\n');
[~, ~, ext] = fileparts(path);

if isempty(ext)
    path = [path, '.txt'];
end

if p.Results.Append
    fid = fopen(path, 'a');
else
    fid = fopen(path, 'w');
end

fwrite(fid, formattedJoined);
fwrite(fid, newline);
fwrite(fid, newline);
fclose(fid);
end
