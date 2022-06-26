classdef Annotation
    
    properties
        ProjectPath
        VideoName
        File
        FilePath
        
        AnnotationTable
        Behaviors

        MultiCam = false;
        PrimaryCamera = ''
        CameraNames
    end
    
    methods
        function self = Annotation(project, video)
            if isa(project,'DeepActionProject')
                self.ProjectPath = project.ProjectPath;
            else
                self.ProjectPath = project;
            end

            self.MultiCam = project.ConfigFile.GetParams('MultipleCameras');
            self.PrimaryCamera = project.ConfigFile.GetParams('PrimaryCamera');
            self.CameraNames = project.ConfigFile.GetParams('CameraNames');
            self.CameraNames = sort(self.CameraNames);

            self.VideoName = video;
            
            self.File = sprintf('%s_annotations.mat', video);
            self.FilePath = fullfile(self.ProjectPath, 'annotations', self.VideoName, self.File);


        end

        OverwriteAnnotation(self, replacementT)

        UpdateAnnotations(self, updatedAnnotT)
        
        behaviors = GetBehaviors(self)
        
        UpdateBehaviorSet(self, behaviorSet)

        [annotIdxs, unannotIdx] = GetAnnotationIndices(self)
        
        InitializeAnnotation(self)
        
        Save(self)

        ts = GetTimeStamps(self)
        
        self = Load(self, varargin)

        annotT = GetAnnotations(self, varargin)
        
        AddFileAnnotations(self, annotFilePath, overwrite)
    end
end

