function annotT = GetAnnotations(self, varargin)
self = Load(self);

if ~isempty(self.AnnotationTable)
    return
end

annotT = self.AnnotationTable;

if nargin == 2
    indices = varargin{1};
    annotT = annotT(indices, :);
end
end