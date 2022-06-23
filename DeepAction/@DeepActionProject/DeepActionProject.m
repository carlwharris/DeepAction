classdef DeepActionProject
    properties
        ProjectPath
        ProjectName
        VerboseLevel = 1
        ConfigFile
        ClipTable
        Layers
        TrainingOptions
        Network
        ConfidenceScorer
        Results
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


        function allAnnotT = LoadAllAnnotations(self)
            VideoName = self.GetVideoNames('annotations');

            Annotations = {};
            for i = 1:length(VideoName)
                currAnnot = Annotation(self, VideoName{i});
                includeAll = true;
                currAnnot = currAnnot.Load(includeAll);
                currAnnotT = currAnnot.AnnotationTable;

                
                Annotations = [Annotations; {currAnnotT}];
            end

            allAnnotT = table(VideoName, Annotations);
        end

        function SaveAllAnnotations(self, allAnnotT)
            for i = 1:size(allAnnotT)
                currAnnot = Annotation(self, allAnnotT.VideoName{i});
                currAnnot.OverwriteAnnotation(allAnnotT.Annotations{i})
            end
        end

        
        function CreateProject(self)
            % Create new DeepAction project
            if ~isfolder(self.ProjectPath)
                mkdir(self.ProjectPath)
            end

            self.ConfigFile.CreateConfigFile()
        end

        function self = LaunchAnnotator(self)
            self.BackupAnnotations()
            Annotator(self)
%             clipTPath = fullfile(self.ProjectPath, 'annotations', 'AnnotatorClipTable.mat');
%             s = load(clipTPath, 'AnnotatorClipTable');
%             self.ClipTable = s.ClipTable;
        end

        CreateLabeledVideos(self, varargin)

        function self = GetClassifierData(self)
            if self.VerboseLevel > 0
                fprintf('Creating clips and loading clip data to train the classifier...\n')
            end
            
            self = self.CreateClipTable('IncludeFeatures', true);
            self = self.LoadData('IncludeFeatures', true);
        end

        function fps = GetAverageFrameRate(self)
            videoNames = GetVideoNames(self);

            totalTime = 0;
            totalFrames = 0;
            for i = 1:length(videoNames)
                currAnnot = Annotation(self, videoNames{i});
                ts = currAnnot.GetTimeStamps();

                if ~isempty(ts)
                    totalTime = totalTime + ts(end);
                    totalFrames = totalFrames + length(ts);
                end
            end

            fps = totalFrames / totalTime;
        end

        

        function self = GetAnnotatorData(self)
            % Set up data for manual annotation
            self = self.CreateClipTable('IncludeFeatures', false);
            self = self.LoadData('IncludeFeatures', false);
        end

        function SaveClassifier(self)
            if isempty(self.Network)
                fprintf('No classifier has been trained!');
                return
            end

            t = now;
            d = datetime(t,'ConvertFrom','datenum');

            d.Format = 'yyyy-MM-dd_HH-mm-ss';
            destFolder = fullfile(self.ProjectPath, 'classifiers', char(d));

            mkdir(destFolder)

            if self.VerboseLevel > 1
                fprintf('Saving classifier to ./classifiers/%s... ', char(d))
            end

            Network = self.Network;
            save(fullfile(destFolder, 'Network.mat'), 'Network');

            if self.VerboseLevel > 1
                fprintf('complete\n')
            end
        end

        function self = LoadSavedClassifier(self, varargin)
            parentFolder = fullfile(self.ProjectPath, 'classifiers');

            if nargin == 1
                subfolders = GetValidSubFolders(parentFolder);
                version = subfolders.name{end};
            else
                version = varargin{1};
            end

            srcFolder = fullfile(parentFolder, version);

            if ~isfolder(srcFolder)
                fprintf('Network %s does not exist!\n', version)
                return
            end

            path = fullfile(srcFolder, 'Network.mat');
            s = load(path, 'Network');

            self.Network = s.Network;

            if self.VerboseLevel > 0
                fprintf('Successfully loaded network %s\n', version)
            end
        end

        ExportAnnotations(self)
        self = CreateClipTable(self, varargin)
        
        function self = GenerateClipPredictions(self)
            % Generate predicted labels for each clip

            if self.VerboseLevel > 0
                fprintf('Generating clip predictions... ')
            end

            mbSize = self.ConfigFile.GetParams('PredictionMiniBatchSize');

            seqT = SplitClipDataIntoSequences(self, self.ClipTable);
            features = TransposeCellArrayElements(seqT.Features);
            predictions = classify(self.Network, features, 'MiniBatchSize', mbSize);
            predictions = TransposeCellArrayElements(predictions);

            isRev = seqT.Type == categorical({'R'});
            for i = 1:size(seqT, 1)
                if any(strcmp('Prediction', seqT.Annotations{i}.Properties.VariableNames))
                    seqT.Annotations{i} = removevars(seqT.Annotations{i}, 'Prediction');
                end
                currPredictions = predictions{i};
                seqT.Annotations{i}.Prediction = currPredictions;

                if isRev(i)
                    continue
                end

                notAnnot = seqT.Annotations{i}.Type == categorical({'C'}) | ...
                           seqT.Annotations{i}.Type == categorical({'UL'});

                seqT.Annotations{i}.Label(notAnnot) = currPredictions(notAnnot);
                seqT.Annotations{i}.Type(notAnnot) = categorical({'C'});
            end

            self.ClipTable = CollapseSequencesIntoClips(seqT);
            if self.VerboseLevel > 0
                fprintf('complete\n')
            end
            
        end

        function SyncAnnotationCategories(self)
            folders = GetValidSubFolders(fullfile(self.ProjectPath, 'annotations'));

            behaviors = {};
            for i = 1:size(folders,1)
                currVideo = folders.name{i};

                currAnnot = Annotation(self, currVideo);
                currBehaviors = currAnnot.GetBehaviors();

                behaviors = [behaviors; currBehaviors];
            end
            behaviors = unique(behaviors);

            for i = 1:size(folders,1)
                currVideo = folders.name{i};
                currAnnot = Annotation(self, currVideo);
                currAnnot.UpdateBehaviorSet(behaviors)
            end
        end

        function behaviors = GetAnnotationCategories(self)
            folders = GetValidSubFolders(fullfile(self.ProjectPath, 'annotations'));

            behaviors = {};
            for i = 1:size(folders,1)
                currVideo = folders.name{i};

                currAnnot = Annotation(self, currVideo);
                currBehaviors = currAnnot.GetBehaviors();

                behaviors = [behaviors; currBehaviors];
            end
            behaviors = unique(behaviors);
        end

        function UpdateAnnotationsFromClipTable(self, varargin)
            if nargin == 2
                clipTable = varargin{1};
            else
                clipTable = self.ClipTable;
            end

            uniqueVids = unique(clipTable.Video);

            for i = 1:length(uniqueVids)
                isCurrVid = strcmp(clipTable.Video, uniqueVids{i});
                currVidT = clipTable(isCurrVid, :);
                currAnnotT = vertcat(currVidT.Annotations{:});

                currAnnot = Annotation(self, uniqueVids{i});
                currAnnot.UpdateAnnotations(currAnnotT)
            end
        end

        self = GetClipTable(self, varargin)

        GenerateFrames(self, varargin)
        
        GenerateActivations(self)

        GenerateRICAModel(self)

        self = SplitClipData(self, varargin)

        self = LoadData(self, varargin);

        self = SetUpClassifier(self, varargin)
        
        self = TrainNetwork(self)
        self = TrainClassifier(self)
        self = EvaluateNetwork(self)

        SaveResults(self, varargin)

        videoNames = GetVideoNames(self, varargin)
        ImportAnnotations(self, importTable, varargin)
        ImportVideos(self, importTable, varargin)

        seqT = SplitClipDataIntoSequences(self, clipT)

        function self = GenerateConfidenceScores(self)
            self = self.TrainConfidenceScorer();
            self.ClipTable = self.ConfidenceScorer.GenerateClipScores(self.ClipTable);
            self = self.EvaluateConfidenceScorer();
        end

        function ExtractFeatures(self, varargin)
            p = inputParser;
            p.KeepUnmatched=true;
            addOptional(p, 'parallelize', false);
            parse(p,varargin{:});

            vidNames = GetVideoNames(self, 'frames');
            verboseLvl = self.ConfigFile.GetParams('VerboseLevel');

            streams = self.ConfigFile.GetParams('Streams');
            cams = self.ConfigFile.GetParams('CameraNames');
            
            if p.Results.parallelize
                parStreams = repmat(streams', length(vidNames), 1);
                parVidNames = repmat(vidNames, length(streams), 1);

                parfor i = 1:length(parStreams)
                    tic;
                    feat = Feature(self, parVidNames{i}, parStreams{i}, cams);
                    feat.ExtractFeatures(varargin{:})
                    endTime = toc;
                    fprintf('Video %s, stream %s extracted in %0.1f sec.\n', parStreams{i}, parVidNames{i}, endTime)
                end
            else
                for i = 1:length(streams)
                    for j = 1:length(vidNames)
                        feat = Feature(self, vidNames{j}, streams{i}, cams);
        
                        if verboseLvl > 0
                            fprintf('Extracting %s stream from video %s: ', streams{i}, vidNames{j})
                        end
                        feat.ExtractFeatures()
                    end
                end
            end
        end
        
                % Features
        status = GetFeatureIndices(self)
        
        % Data
        self = GenerateTrainingClips(self)
        [RICAModel, path] = LoadRICAModel(self)
        status = GetAnnotationIndices(self)

        clipT = LoadAnnotations(self, clipT);
        clipT = LoadFeatures(self, clipT, varargin)

        % Classifier
        [trnClipNos, valClipNos, testClipNos] = RandomlySelectClipIndices(self, clipT)
        

        % Confidence scores
        self = TrainConfidenceScorer(self)
        self = EvaluateConfidenceScorer(self)


    end

    methods (Access = private)
        

        function InitializeAnnotations(self)

            if self.VerboseLevel > 0
                fprintf('  Initializing annotations:  ')
            end

            vidNames = GetVideoNames(self, 'videos');
        
            for i = 1:length(vidNames)
                annot = Annotation(self, vidNames{i});
                annot.InitializeAnnotation()
    
                if self.VerboseLevel > 0
                    ProgressBar(i, length(vidNames))
                end
            end
            
        end

        function BackupAnnotations(self)
            t = now;
            d = datetime(t,'ConvertFrom','datenum');

            d.Format = 'yyyy-MM-dd_HH-mm-ss';
            backup_folder = fullfile(self.ProjectPath, 'annotations_backup', char(d));

            mkdir(backup_folder)

            if self.VerboseLevel > 1
                fprintf('Backing up annotations to ./annotations_backup/%s... ', char(d))
            end

            copyfile(fullfile(self.ProjectPath, 'annotations'), backup_folder)

            if self.VerboseLevel > 1
                fprintf('complete\n')
            end
        end
    end

    methods (Static)
        [GlobalScores, ClassScores]  = ScoreClips(seqT)
        annotT = BehaviorArrayToCategorical(annotT)

        function labels = GetLabelsFromTable(t)
            labels = {};

            for i=1:size(t, 1)
                labels = [labels; {t.Annotations{i}.Label}];
            end
        end


    end
end

function behaviorArray = BehaviorArrayFromCategorical(categorical)

catsStr = categories(categorical);

behaviorArray = zeros(length(categorical), length(catsStr));

for i = 1:length(catsStr)
    behaviorArray(categorical == catsStr{i}, i) = 1;
end
end
