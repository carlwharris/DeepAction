classdef DeepActionProject
    properties
        ProjectPath % Path to project folder
        ProjectName % Name of project
        VerboseLevel = 2 % Level of output to display (0-2)
        ConfigFile % ConfigFile object for project's config.txt file 
        ClipTable % Table containing project clip data
        Layers % Layer graph generated during classifier setup
        TrainingOptions % Options for training RNN
        Network % Trained RNN
        ConfidenceScorer % ConfidenceScorer object for project
        Results % Struct containing results of net & confidence eval.
    end

    methods
        function self = DeepActionProject(projectPath)
            self.ProjectPath = projectPath;
            split = regexp(self.ProjectPath,'/','split');
            self.ProjectName = split{end};

            if ~isfolder(self.ProjectPath)
                msg = sprintf('Warning! Project %s with path %s doesn''t exist!\n', self.ProjectName, self.ProjectPath);
                warning(msg)
            end

            configFilePath = fullfile(self.ProjectPath, 'config.txt');
            self.ConfigFile = ConfigFile(configFilePath);

            if isfile(configFilePath)
                self.VerboseLevel = self.ConfigFile.GetParams('VerboseLevel');
            end
        end

        % Create project
        CreateProject(self)

        % Import data
        ImportVideos(self, importTable, varargin)
        ImportAnnotations(self, importTable, varargin)
        SyncAnnotationCategories(self)

        % Generate frames
        GenerateFrames(self, varargin)

        % Generate features
        ExtractFeatures(self, varargin)

        % Create dimensionality reduction model
        GenerateRICAModel(self)

        % GUI
        LaunchAnnotator(self)
        UpdateAnnotationsFromClipTable(self, varargin)
        self = RefreshClipTable(self)
        allAnnotT = LoadAllAnnotations(self)
    
        % Get & load available data
        videoNames = GetVideoNames(self, varargin)
        
        self = GetAnnotatorData(self) % For initial annotation
        self = GetClassifierData(self) % For classifier training

        self = CreateClipTable(self, varargin)
        status = GetFeatureIndices(self) % Get extracted features frames
        status = GetAnnotationIndices(self) % Get annotated frames
        fps = GetAverageFrameRate(self)

        self = LoadData(self, varargin) % Load clip table
        clipT = LoadFeatures(self, clipT, varargin)
        [RICAModel, path] = LoadRICAModel(self)
        clipT = LoadAnnotations(self, clipT);


        % Setup data for training
        self = SplitClipData(self, varargin)
        [trnClipNos, valClipNos, testClipNos] = RandomlySelectClipIndices(self, clipT)

        % Classifier
        self = SetUpClassifier(self, varargin)
        
        self = TrainClassifier(self) % Train net, predict clips, evaluate
        self = TrainNetwork(self)
        self = GenerateClipPredictions(self)
        self = EvaluateNetwork(self)

        SaveClassifier(self)
        self = LoadSavedClassifier(self, varargin)

        seqT = SplitClipDataIntoSequences(self, clipT)

        % Confidence score
        self = GenerateConfidenceScores(self)
        self = TrainConfidenceScorer(self)
        self = EvaluateConfidenceScorer(self)

        % Export/annotation IO        
%         CreateLabeledVideos(self, varargin) TODO
        CreateLabeledClips(self, varargin)

        SaveResults(self, varargin)

        ExportAnnotations(self)
        SaveAllAnnotations(self, allAnnotT)
    end

    methods (Access = private)
        InitializeAnnotations(self)
        BackupAnnotations(self)
    end

    methods (Static)
        [GlobalScores, ClassScores]  = ScoreClips(seqT)
        annotT = BehaviorArrayToCategorical(annotT)
        labels = GetLabelsFromTable(t)
    end
end
