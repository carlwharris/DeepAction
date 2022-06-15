
function CreateConfigFile(self)
[folders, ~, ~] = fileparts(self.FilePath);
split = regexp(folders, '/', 'split');
projectName = split{end};

fileID = fopen(self.FilePath, 'w');

fprintf(fileID,'[Project]\n');
fprintf(fileID,'  ProjectName=''%s''\n', projectName);
fprintf(fileID,'  MultipleCameras=false\n');
fprintf(fileID,'  CameraNames=[]\n');
fprintf(fileID,'  PrimaryCamera=''''\n');
fprintf(fileID,'  VerboseLevel=3\n');

fprintf(fileID,'\n[Stream]\n');
fprintf(fileID,'  ImageType=image\n');
fprintf(fileID,'  ImageExtension=''.png''\n');
fprintf(fileID,'  SpatialStream=true\n');
fprintf(fileID,'  TemporalStream=true\n');
fprintf(fileID,'  Method=Farneback\n');
fprintf(fileID,'  ResizeFlow=true\n');
fprintf(fileID,'  FlowImageSize=[224, 224]\n');

fprintf(fileID,'\n[Features]\n');
fprintf(fileID,'  FeatureExtractor=ResNet18\n');
fprintf(fileID,'  CNNMiniBatchSize=128\n');
fprintf(fileID,'  FlowStackSize=10\n');
fprintf(fileID,'  ReduceDimensionality=true\n');
fprintf(fileID,'  NumDimensions=512\n');
fprintf(fileID,'  SamplePoints=1\n');
fprintf(fileID,'  IterationLimit=1000\n');

fprintf(fileID,'\n[Annotations]\n');
fprintf(fileID,'  ClipLength=60\n');

fprintf(fileID,'\n[Classifier]\n');
fprintf(fileID,'  SequenceLength=450\n');
fprintf(fileID,'  NumberHiddenUnits=64\n');
fprintf(fileID,'  NumberLayers=2\n');
fprintf(fileID,'  DropoutRatio=0.50\n');
fprintf(fileID,'  ClassificationLayer=''cross-entropy''\n');

fprintf(fileID,'\n[TrainingOptions]\n');
fprintf(fileID,'  MiniBatchSize=8\n');
fprintf(fileID,'  MaxExpochs=16\n');
fprintf(fileID,'  ValidationFreqEpoch=1\n');
fprintf(fileID,'  ValidationPatience=2\n');
fprintf(fileID,'  InitialLearningRate=0.001\n');
fprintf(fileID,'  LearningRateDropPeriod=4\n');
fprintf(fileID,'  LearningRateDropFactor=0.1\n');

fprintf(fileID,'\n[Evaluation]\n');
fprintf(fileID,'  PredictionMiniBatchSize=256\n');
fprintf(fileID,'  TrainProportion=0.50\n');
fprintf(fileID,'  ValidationProportion=0.20\n');
fprintf(fileID,'  TestProportion=0.30\n');

fprintf(fileID,'\n[ConfidenceScoring]\n');
fprintf(fileID,'  ScoringMethod=''TemperatureScaling''\n');
% fprintf(fileID,'  ClipCalibrationModel=''none''\n');

fclose(fileID);
end

