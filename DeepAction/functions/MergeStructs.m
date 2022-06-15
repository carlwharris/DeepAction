function struct = MergeStructs(struct, varargin)
% varargin - struct2, struct3, struct4, etc.

for i = 2:nargin
    currStruct = varargin{i-1};
    
    fields = fieldnames(currStruct);
    for j = 1:length(fields)
        currFieldName = fields{j};
        struct.(currFieldName) = currStruct.(currFieldName);
    end
end
end