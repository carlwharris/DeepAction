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

        function OverwriteAnnotation(self, replacementT)
            self.AnnotationTable = replacementT;
            self.Save();
        end

        function UpdateAnnotations(self, updatedAnnotT)
            self = Load(self);
            
            updatedFrame = updatedAnnotT.Frame;
            updatedType = updatedAnnotT.Type;
            updatedLabel = updatedAnnotT.Label;

            [~, loc] = ismember(updatedFrame, self.AnnotationTable.Frame);
            self.AnnotationTable.Type(loc) = updatedType;
            self.AnnotationTable.Label(loc) = updatedLabel;
            

%             self.AnnotationTable(startUpdate:endUpdate, :) = updatedAnnotT;

            self.Save()
        end

        function behaviors = GetBehaviors(self)
            self = self.Load();
            behaviors = categories(self.AnnotationTable.Label);
        end
        
        function UpdateBehaviorSet(self, behaviorSet)
            self = self.Load();
            self.AnnotationTable.Label = addcats(self.AnnotationTable.Label, behaviorSet);
            self.Save()
        end
        
        function [annotIdxs, unannotIdx] = GetAnnotationIndices(self)
            self = self.Load();
            
            if isempty(self.AnnotationTable)
                annotIdxs = [];
                unannotIdx = [];
                return
            end

            isAnnot = self.AnnotationTable.Type == categorical({'I'}) | ...
                      self.AnnotationTable.Type == categorical({'A'}) | ...
                      self.AnnotationTable.Type == categorical({'R'});
            annotIdxs = self.AnnotationTable.Frame(isAnnot);
            unannotIdx = self.AnnotationTable.Frame(~isAnnot);
        end
        
        function InitializeAnnotation(self)
            if isfile(self.FilePath)
                return
            end

            if self.MultiCam
                videoFolderPath = fullfile(self.ProjectPath, 'videos', self.VideoName, self.CameraNames{1});

                file = GetValidFolderFiles(videoFolderPath);

                [~, ~, ext] = fileparts(file.name);
                file(strcmp(ext, '.mat'),:) = [];
                videoPath = fullfile(file.folder{1}, file.name{1});
    
                fr = FrameReader(videoPath);

                if strcmp(fr.ImageType, 'sequence')
                    timeStamps = fr.SeqTS;
                else
                    timeStamps = [];
                    while HasFrame(fr)
                        [fr, ~, ts] = fr.ReadFrame();
                        timeStamps = [timeStamps; ts];
                    end
                end
                fr.Close();
                
                for i = 2:length(self.CameraNames)
                    videoFolderPath = fullfile(self.ProjectPath, 'videos', self.VideoName, self.CameraNames{i});

                    file = GetValidFolderFiles(videoFolderPath);
    
                    [~, ~, ext] = fileparts(file.name);
                    file(strcmp(ext, '.mat'),:) = [];
                    videoPath = fullfile(file.folder{1}, file.name{1});
%         
                    fr = FrameReader(videoPath);

                    if strcmp(fr.ImageType, 'sequence')
                        currCamTimeStamps = fr.SeqTS;
                    else
                        currCamTimeStamps = [];
                        while HasFrame(fr)
                            [fr, ~, ts] = fr.ReadFrame();
                            currCamTimeStamps = [currCamTimeStamps; ts];
                        end
                    end
                    fr.Close()

                    if size(timeStamps, 1) > size(currCamTimeStamps,1)
                        diff = size(timeStamps, 1) - size(currCamTimeStamps,1);
                        tmp = nan(diff, 1);
                        currCamTimeStamps = [currCamTimeStamps; tmp];
                    end

                    if size(timeStamps, 1) < size(currCamTimeStamps,1)
                        diff = size(currCamTimeStamps,1) - size(timeStamps, 1);
                        tmp = nan(diff, size(timeStamps, 2));
                        timeStamps = [timeStamps; tmp];
                    end

                    timeStamps = [timeStamps currCamTimeStamps];
                end

                timeStamps = array2table(timeStamps, 'VariableNames',self.CameraNames);
            else
                videoFolderPath = fullfile(self.ProjectPath, 'videos', self.VideoName);

                file = GetValidFolderFiles(videoFolderPath);

                [~, ~, ext] = fileparts(file.name);
                file(strcmp(ext, '.mat'),:) = [];
                videoPath = fullfile(file.folder{1}, file.name{1});
    
                fr = FrameReader(videoPath);
                timeStamps = [];
                while HasFrame(fr)
                    [fr, ~, ts] = fr.ReadFrame();
                    timeStamps = [timeStamps; ts];
                end
                fr.Close();

                timeStamps = table(timeStamps, 'VariableNames', {'TimeStamp'});
            end
            
            % Types
            % I - imported
            % A - annotated
            % C - classifier labels
            % R - reviewed
            % UL - unlabeled
            typeStr = repmat({'UL'}, size(timeStamps, 1), 1);
            types = categorical(typeStr, {'I', 'A','R', 'C', 'UL'});
            frameIdxs = [1:size(timeStamps,1)]';
            
            labelsStr = repmat({'UL'}, size(timeStamps,1), 1);
            labels = categorical(labelsStr, {'UL'});
            emptyT = table(frameIdxs, timeStamps, types, labels, ...
            'VariableNames', ...
            {'Frame', 'TimeStamp', 'Type', 'Label'});

            self.AnnotationTable = emptyT;
            self.Save()


        end

        function Save(self)
            % Save annotations table to file
            
            AnnotationTable = self.AnnotationTable;
            
            currFolder = fullfile(self.ProjectPath, 'annotations', self.VideoName);
            if ~isfolder(currFolder)
                mkdir(currFolder)
            end
            
            save(self.FilePath, 'AnnotationTable');
        end
        
        function ts = GetTimeStamps(self)
            self = self.Load();

            if isempty(self.AnnotationTable)
                ts = [];
                return
            end

            if self.MultiCam
                ts = self.AnnotationTable.TimeStamp;
                ts = ts.(self.PrimaryCamera);
            else
                ts = self.AnnotationTable.TimeStamp.TimeStamp;
            end
        end

        function self = Load(self, varargin)
            % Load annotation table from file

            if nargin == 2
                includeAll = true;
            else
                includeAll = false;
            end
            
            if ~isfile(self.FilePath)
                return
            end

            s = load(self.FilePath, 'AnnotationTable');
            self.AnnotationTable = s.AnnotationTable;

            if self.MultiCam && ~includeAll
                ts = self.AnnotationTable.TimeStamp;
                notNan = ~isnan(ts.(self.PrimaryCamera));
                self.AnnotationTable = self.AnnotationTable(notNan, :);
            end
        end
        
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

        function AddFileAnnotations(self, annotFilePath, overwrite)
            % Add annotations contained in 'annotFilePath' to annotations
            % table
            
            self = Load(self);

            if isempty(self.AnnotationTable)
                return
            end
            
            fileAnnots = readtable(annotFilePath);
            annotT = self.AnnotationTable;

            if overwrite
                labelsStr = repmat({'UL'}, size(annotT,1), 1);
                annotT.Label = categorical(labelsStr, {'UL'});
            end

            annotTVarNames = fileAnnots.Properties.VariableNames;
            annotTBehaviors = annotTVarNames(~strcmp('Frame', annotTVarNames));

            annotT.Label = addcats(annotT.Label, annotTBehaviors);
            for i = 1:length(annotTBehaviors)
                currLabel = annotTBehaviors{i};
                frameIdxs = fileAnnots.Frame(fileAnnots.(currLabel) == 1);

                annotT.Label(frameIdxs) = categorical({currLabel});
                annotT.Type(frameIdxs) = categorical({'I'});
            end

            self.AnnotationTable = annotT;
            self.Save()
        end

    end
end

