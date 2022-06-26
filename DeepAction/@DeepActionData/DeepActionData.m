classdef DeepActionData < DeepActionProject
    %DEEPACTIONDATA Summary of this class goes here
    %   Detailed explanation goes here
    
    properties
        Property1
    end
    
    methods
        function self = DeepActionData(projectPath)
            self = self@DeepActionProject(projectPath)
        end
        
        self = CreateClipTable(self, varargin)
        status = GetFeatureIndices(self)
        status = GetAnnotationIndices(self)

        self = LoadData(self, varargin)
        clipT = LoadFeatures(self, clipT)
        clipT = LoadAnnotations(self, clipT)
    end
end

