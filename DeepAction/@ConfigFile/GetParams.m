function queryVal = GetParams(self, varargin)
% queryValStruct = GetParams(self, 'project')
% queryVal = GetParams(self, 'CameraNames')
% queryVal = GetParams(self, 'project', 'CameraNames')

self = GenerateParams(self);

params = self.Params;

if nargin == 3
    section = varargin{1};
    query = varargin{2};
    queryVal = SearchWithSection(params, section, query);
else
    query = varargin{1};
    
    sectionFields = fieldnames(params);
    
    for i = 1:length(sectionFields)
        if strcmpi(sectionFields{i}, query)
            queryVal = params.(sectionFields{i});
            return
        end
    end
    queryVal = SearchNoSection(params, query);
end
end

function queryVal = SearchWithSection(paramsS, section, query)
sectionFields = fieldnames(paramsS);

for i = 1:length(sectionFields)
    if ~strcmpi(sectionFields{i}, section)
        continue
    end
    
    currSection = paramsS.(sectionFields{i});
    paramFields = fieldnames(currSection);
    
    for j = 1:length(paramFields)
        if strcmpi(paramFields{j}, query)
            queryVal = currSection.(paramFields{j});
            return
        end
    end
end
fprintf('Query %s not found in section %s params!\n', query, section)

end

function queryVal = SearchNoSection(paramsS, query)
sectionFields = fieldnames(paramsS);

for i = 1:length(sectionFields)
    currSection = paramsS.(sectionFields{i});
    paramFields = fieldnames(currSection);
    
    for j = 1:length(paramFields)
        if strcmpi(paramFields{j}, query)
            queryVal = currSection.(paramFields{j});
            return
        end
    end
end
fprintf('Query %s not found in params!\n', query)

end