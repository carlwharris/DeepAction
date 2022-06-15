classdef Feature < DeepActionProject
    %FEATURES Summary of this class goes here
    %   Detailed explanation goes here
    
    properties
        VideoName
        Stream
        Camera
    end
    
    methods
        function self = Feature(project, vidName, stream, camera)
            self = self@DeepActionProject(project.ProjectPath);
            self.VideoName = vidName;
            self.Stream = stream;
            self.Camera = camera;
        end
        
        function indices = GetFeatureIndices(self)
            baseNetwork = self.ConfigFile.GetParams('FeatureExtractor');
            fileName = sprintf('%s_%s_Features.mat', self.VideoName, baseNetwork);

            if self.ConfigFile.GetParams('MultipleCameras')
                path = fullfile(self.ProjectPath, 'features', self.Stream, self.VideoName, self.Camera, fileName);
            else
                path = fullfile(self.ProjectPath, 'features', self.Stream, self.VideoName, fileName);
            end

            if ~isfile(path)
                indices = [];
                return
            end

            file = matfile(path);

%             feat = load(path, 'Features');
            nRows = size(file.Features, 1);
            indices = [1:nRows]';
        end

        function feats = LoadFeatures(self)
            baseNetwork = self.ConfigFile.GetParams('FeatureExtractor');
            fileName = sprintf('%s_%s_Features.mat', self.VideoName, baseNetwork);

            if isempty(self.Camera)
                path = fullfile(self.ProjectPath, 'features', self.Stream, self.VideoName, fileName);
            else
                path = fullfile(self.ProjectPath, 'features', self.Stream, self.VideoName, self.Camera, fileName);
            end

            if ~isfile(path)
                feats = [];
                return
            end

            feats = load(path, 'Features');
            feats = feats.Features;
        end

        function GenerateFrames(self, varargin)
            p = inputParser;
            p.KeepUnmatched=true;
            addOptional(p, 'parallelize', false);
            parse(p,varargin{:});
            
            parallelize = p.Results.parallelize;

            if strcmp(self.Stream, 'spatial')
                inFolder = fullfile(self.ProjectPath, 'videos', self.VideoName);

                if isempty(self.Camera)
                    outFolder = fullfile(self.ProjectPath, 'frames', 'spatial', self.VideoName);
                else
                    outFolder = fullfile(self.ProjectPath, 'frames', 'spatial', self.VideoName, camera);
                end
            else
                if isempty(self.Camera)
                    inFolder = fullfile(self.ProjectPath, 'frames', 'spatial', self.VideoName);
                    outFolder = fullfile(self.ProjectPath, 'frames', 'temporal', self.VideoName);
                else
                    inFolder = fullfile(self.ProjectPath, 'frames', 'spatial', self.VideoName, camera);
                    outFolder = fullfile(self.ProjectPath, 'frames', 'temporal', self.VideoName, camera);
                end
            end

            if ~isfolder(outFolder)
                mkdir(outFolder)
            end

            imgType = self.ConfigFile.GetParams('ImageType');
            if strcmp(imgType, 'sequence')
                outPath = fullfile(outFolder, [self.VideoName '.seq']);
            elseif strcmp(imgType, 'image')
                outPath = outFolder;
            elseif strcmp(imgType, 'video')
                outPath = fullfile(outFolder, [self.VideoName '.mp4']);
            end

            if strcmp(imgType, 'sequence') || strcmp(imgType, 'video')
                writerExists = isfile(outPath);
            else
                if ~isempty(GetValidFolderFiles(outPath))
                    writerExists = true;
                else
                    writerExists = false;
                end
            end

            [files, ~] = GetValidFolderFiles(inFolder);
            if isempty(files)
                return
            end
            
            [~, ~, ext] = fileparts(files.name{1});
            
            if strcmp(ext, '.png') || strcmp(ext, '.jpg')
                inPath = inFolder;
            else
                [~, ~, exts] = fileparts(files.name);
                isSelFile = strcmp('.seq', exts) | strcmp('.mp4', exts) | strcmp('.mpg', exts) ...
                    | strcmp('.avi', exts);
                inPath = fullfile(files.folder{isSelFile}, files.name{isSelFile});
            end

            
            frameReader = FrameReader(inPath);
            if writerExists == true
                try
                    frTmp = FrameReader(outPath);
                    if frameReader.NumFrames == frTmp.NumFrames
                        return
                    else
                        if strcmp(imgType, 'image')
                            rmdir(outPath, 's')
                        else
                            delete(outPath, 's')
                        end
                    end
                catch
                    if strcmp(imgType, 'image')
                        rmdir(outPath, 's')
                    else
                        delete(outPath, 's')
                    end
                end
            end

            if strcmp(imgType, 'image')
                imgExt = self.ConfigFile.GetParams('ImageExtension');
                frameWriter = FrameWriter(outPath, 'FrameRate', frameReader.FrameRate, ...
                    'Extension', imgExt);
            else
                frameWriter = FrameWriter(outPath, 'FrameRate', frameReader.FrameRate);
            end

            if strcmp(self.Stream, 'spatial')
                GenerateSpatialFrames(self, frameReader, frameWriter, parallelize)
            elseif strcmp(self.Stream, 'temporal')
                GenerateTemporalFrames(self, frameReader, frameWriter, parallelize)
            end
        end
        
        function ExtractFeatures(self, varargin)
            p = inputParser;
            p.KeepUnmatched=true;
            addOptional(p, 'parallelize', false);
            parse(p,varargin{:});

            baseNetwork = self.ConfigFile.GetParams('FeatureExtractor');
            if strcmp(baseNetwork, 'ResNet50')
                netCNN = resnet50;
                activationLayer = 'avg_pool';
                nFeatures = 2048;
            elseif strcmp(baseNetwork, 'ResNet18')
                netCNN = resnet18;
                activationLayer = 'pool5';
                nFeatures = 512;
            elseif strcmp(baseNetwork, 'GoogLeNet')
                netCNN = googlenet;
                activationLayer   = 'pool5-7x7_s1';
                nFeatures = 1024;
            elseif strcmp(baseNetwork, 'VGG-16')
                netCNN = vgg16;
                activationLayer = 'fc7';
                nFeatures = 4096;
            elseif strcmp(baseNetwork, 'VGG-19')
                netCNN = vgg19;
                activationLayer = 'fc7';
                nFeatures = 4096;
            elseif strcmp(baseNetwork, 'InceptionResNetv2')
                netCNN = inceptionresnetv2;
                activationLayer = 'avg_pool'; 
                nFeatures = 1536;
            else
                disp('Enter Valid Network Name')
            end
            
            nStackedFrames = self.ConfigFile.GetParams('FlowStackSize');
            
            stackInput = false;
            if nStackedFrames > 1 && strcmp(self.Stream, 'temporal')
                stackInput = true;
                netCNN = CreateNetworkedStackedInput(netCNN, nStackedFrames);
            end
            
            if ~isempty(self.Camera)
                currInFolder = fullfile(self.ProjectPath, 'frames', self.Stream, self.VideoName, self.Camera);
                currOutFolder = fullfile(self.ProjectPath, 'features', self.Stream, self.VideoName, self.Camera);
            else
                currInFolder = fullfile(self.ProjectPath, 'frames', self.Stream, self.VideoName);
                currOutFolder = fullfile(self.ProjectPath, 'features', self.Stream, self.VideoName);
            end

            if ~isfolder(currInFolder)
                return
            end
            
            [files, ~] = GetValidFolderFiles(currInFolder);

            if isempty(files)
                return
            end

            [~, ~, ext] = fileparts(files.name{1});
            
            if strcmp(ext, '.png') || strcmp(ext, '.jpg')
                inPath = currInFolder;
            else
                [~, ~, exts] = fileparts(files.name);
                isSelFile = strcmp('.seq', exts) | strcmp('.mp4', exts) | strcmp('.mpg', exts) ...
                    | strcmp('.avi', exts);
                inPath = fullfile(files.folder{isSelFile}, files.name{isSelFile});
            end

            if ~isfolder(currOutFolder)
                mkdir(currOutFolder)
            end

            fileName = sprintf('%s_%s_Features.mat', self.VideoName, baseNetwork);
            outPath = fullfile(currOutFolder, fileName);
            if isfile(outPath)
                return
            end

            
            fr = FrameReader(inPath);
            nFrames = fr.NumFrames;
            
            miniBatchSize = self.ConfigFile.GetParams('CNNMiniBatchSize');
            miniBatchIndices = GetMinibatchIndices(miniBatchSize, nFrames);
            
            verboseLvl = self.ConfigFile.GetParams('VerboseLevel');

            Features = zeros(nFrames, nFeatures);
            inputSize = netCNN.Layers(1).InputSize;
            for i = 1:size(miniBatchIndices,1)
                currIdxs = miniBatchIndices{i};
            
                h = fr.Dimensions(1);
                w = fr.Dimensions(2);
                if stackInput == true
                    imgs = zeros(h, w, nStackedFrames*3, length(currIdxs), 'uint8');
                else
                    imgs = zeros(h, w, 3, length(currIdxs), 'uint8');
                end
            
                for j = 1:length(currIdxs)
            
                    if stackInput == true
                        [startIdx, endIdx] = GetStackStartEnd(currIdxs(j), nStackedFrames, nFrames);
                        vals = zeros(h, w, nStackedFrames*3);
            
                        cnt = 0;
                        for k = startIdx:endIdx
                            [fr, frame, ts] = ReadFrame(fr, k);
            
                            currStartIdx = cnt * 3 + 1;
                            currEndIdx = currStartIdx + 2;
                            vals(:, :, currStartIdx:currEndIdx) = frame;
                            cnt = cnt+1;
                        end
                        imgs(:,:,:,j) = uint8(vals);
                    else
                        [fr, frame, ts] = ReadFrame(fr, currIdxs(j));
                        imgs(:,:,:,j) = frame;
                    end
                end

                imds = augmentedImageDatastore(inputSize(1:2), imgs, 'ColorPreprocessing', 'gray2rgb');
            
                currFeatures = activations(netCNN, imds, activationLayer, 'OutputAs', 'rows', 'MiniBatchSize', miniBatchSize);
                Features(currIdxs,:) = currFeatures;
            
                if verboseLvl > 1 && ~p.Results.parallelize
                    ProgressBar(currIdxs(1), nFrames, 'TotalUpdates', inf)
                end
            end
            
            Info = struct;
            Info.CreationTime = datetime('now');
            Info.BaseNetwork = baseNetwork;
            Info.ActivationLayer = activationLayer;
            Info.NFeatures = size(Features, 2);
            Info.NFrames = size(Features, 1);
            
            save(outPath, 'Features', 'Info', '-v7.3','-nocompression');
        end
    end

    methods (Access = protected)
        function GenerateSpatialFrames(self, frameReader, frameWriter, parallelize)
            verboseLvl = self.ConfigFile.GetParams('VerboseLevel');

            frameNo = 1;
            while HasFrame(frameReader)
                if verboseLvl > 1 && ~parallelize
                    ProgressBar(frameNo, frameReader.NumFrames);
                end

                [frameReader, frame, ts] = ReadFrame(frameReader);
                frameWriter = WriteFrame(frameWriter, frame, ts);
                frameNo = frameNo + 1;
            end
            Close(frameWriter);
        end

        function GenerateTemporalFrames(self, frameReader, frameWriter, parallelize)
            verboseLvl = self.ConfigFile.GetParams('VerboseLevel');
            flowType = self.ConfigFile.GetParams('Method');

            resizeFlow = self.ConfigFile.GetParams('ResizeFlow');
            scale = self.ConfigFile.GetParams('FlowImageSize');

            if ~resizeFlow
                scale = [];
            end
            
            if strcmpi(flowType, 'Farneback')
                opticFlow = opticalFlowFarneback;
            end

            prevFrame = [];
            frameNo = 1;
            while HasFrame(frameReader)
                [frameReader, currFrame, ts] = ReadFrame(frameReader);
        
                if isempty(prevFrame)
                    prevFrame = currFrame;
                end
        

                if strcmpi(flowType, 'Farneback')
                    if ~isempty(scale)
                        currFrame = imresize(currFrame, scale, 'bilinear');
                    end

                    frameGray = im2gray(currFrame);
                    estFlow = estimateFlow(opticFlow, frameGray);
                    flow = cat(3, estFlow.Vx, estFlow.Vy);
                elseif strcmpi(flowType, 'TV-L1')
                    if ~isempty(scale)
                        prevFrame = imresize(prevFrame, scale, 'bilinear');
                        currFrame = imresize(currFrame, scale, 'bilinear');
                    end
                    flow = CalculateFlowMatrix(prevFrame, currFrame);
                end

                ctFrame = flowToColor(flow);
                frameWriter = frameWriter.WriteFrame(ctFrame, ts);
        
                if verboseLvl > 1 && ~parallelize
                    ProgressBar(frameNo, frameReader.NumFrames);
                end

                prevFrame = currFrame;
                frameNo = frameNo + 1;
            end
            Close(frameWriter);
        end
    end
end


function net = CreateNetworkedStackedInput(netCNN, nStackedFrames)
inputLayer = netCNN.Layers(1);
inputSize = inputLayer.InputSize;

newLayerMean = repmat(inputLayer.Mean, [1 1 nStackedFrames]);
newLayerStdev = repmat(inputLayer.StandardDeviation, [1 1 nStackedFrames]);

newLayer = imageInputLayer([inputSize(1:2) 3*nStackedFrames], ...
            'Name', inputLayer.Name, ...
            'Normalization', inputLayer.Normalization, ...
            'NormalizationDimension', inputLayer.NormalizationDimension, ...
            'Mean', newLayerMean, ...
            'StandardDeviation', newLayerStdev, ...
            'Min', inputLayer.Min, ...
            'Max', inputLayer.Max, ...
            'DataAugmentation', inputLayer.DataAugmentation);

C2dLayer = netCNN.Layers(2);
newWeights = repmat(C2dLayer.Weights, [1 1 nStackedFrames 1]);

newC2DLayer = convolution2dLayer(...
        C2dLayer.FilterSize, ...
        C2dLayer.NumFilters, ...
        'Name', C2dLayer.Name, ...
        'NumChannels', 3*nStackedFrames, ...
        'Stride', C2dLayer.Stride, ...
        'DilationFactor', C2dLayer.DilationFactor, ...
        'Padding', C2dLayer.PaddingSize, ...
        'Weights', newWeights, ...
        'Bias', C2dLayer.Bias);

netLayers = layerGraph(netCNN);
lgraph = replaceLayer(netLayers,inputLayer.Name, newLayer);
lgraph = replaceLayer(lgraph,C2dLayer.Name,newC2DLayer);
net = assembleNetwork(lgraph);
end

function miniBatchIndices = GetMinibatchIndices(miniBatchSize, nFrames)
miniBatchIndices = {};
cnt = 1;
currIdxs = [];
while cnt <= nFrames
    if mod(cnt,(miniBatchSize)) == 0
        currIdxs = [currIdxs; cnt];
        miniBatchIndices = [miniBatchIndices; currIdxs];
        currIdxs = [];
    else
        currIdxs = [currIdxs; cnt];
    end
    cnt = cnt+1;
end
miniBatchIndices = [miniBatchIndices; currIdxs];
end

function [startIdx, endIdx] = GetStackStartEnd(currIdx, stackSize, nTotal)


nBack = stackSize/2 -1;
nForward = stackSize/2;

startIdx = currIdx - nBack;
endIdx = currIdx + nForward;

if startIdx < 1
    diff = 1 - startIdx;
    endIdx = endIdx + diff;
    startIdx = 1;
end

if endIdx > nTotal
    diff = endIdx - nTotal;
    startIdx = startIdx - diff;
    endIdx = nTotal;
end
end

