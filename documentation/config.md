#  DeepAction configuration files

Project parameters and options are controlled via configuration files, saved in the `config.txt` file in the project folder. We group parameters into the section of the workflow to which the apply, denoted in brackets (i.e., `[Project]`, `[Stream]`, `[Features]`, `[Annotations]`, `[Classifier]`, `[TrainingOptions]`, `[Evaluation]`, `[ConfidenceScoring]`). Below are descriptions for each parameter and group.

 Default parameter values are displayed in the heading for each item (i.e., `Parameter=default`).


## `[Project]`

**`ProjectName`** Name of the project, as derived from the project path used to instantiate the object

* *Not editable* (i.e., to change the project, rename the project folder and the `ProjectName` will be updated automatically)

**`MultipleCameras=false`** Option to use multiple cameras

**`CameraNames=[]`** Camera names, in the event of multiple-camera integration

* Must be specified if `MultipleCameras=true`, otherwise ignored
* Specified as an array of characters (e.g., `CameraNames=[cam1, cam2, cam3]`)

**`PrimaryCamera=''`** In the case of multiple camera projects, the primary camera is used for annotation, creation of labeled clips, etc.

* *Example:* `PrimaryCamera='cam1'` sets the primary camera to `cam1`

**`VerboseLevel=3`** Verbosity level of command line output (from 0 to 3)

## `[Stream]`


**`ImageType=image`** Specifies the format for storing extracted spatial and temporal frames   

* `ImageType=image` stores as images with extension ImageExtension  
* `ImageType=video` stores as videos with extension ImageExtension
* `ImageType=sequence` stores the extracted from as sequence files

**`ImageExtension='.png'`** Extension to use for storing extracted frames   

* *Options:*
	* If `ImageType=image`: `'.png'` or `='.jpg'`
	* if `ImageType=video`: `'.mp4'` or `'.avi'`
	* if `ImageType=sequence`: ignored, and uses `'.seq'` extension

**`SpatialStream=true`** Specifies whether to use/create the spatial stream (in generating frames, creating features, and training the classifier)   

**`TemporalStream=true`** Specifies whether to use/create the temporal stream (in generating frames, creating features, and training the classifier) 

**`Method=Farneback`** Method to use to estimate the optical flow between images  

* *Options:*
	* `TV-L1`: uses TV-L1 estimation  
	* `Farneback`: uses the Farneback method, as is substantially faster than TV-L1  

**`ResizeFlow=true`** Option to downsize the images before estimating the optical flow, which decreases runtime   

* If `ResizeFlow=True`, the size of the downsampled images must be specified by `FlowImageSize`  

**`FlowImageSize=[224, 224]`** Size of images used for optical flow estimation (`[numrows, numcols]`)

* The `FlowImageSize` paramter is ignored if `ResizeFlow=False`
* *Note:* the default image size (`[224, 224]`) is the input size of the ResNet18 network

## `[Features]`
**`FeatureExtractor=ResNet18`** Pretrained CNN to use in extracting features from video frames

* Options:`ResNet18`,`ResNet50`,`GoogLeNet`,`VGG-16`,`VGG-19`,`InceptionResNetv2`

**`CNNMiniBatchSize=128`** Batch size to use when extracting activations from the CNN

**`FlowStackSize=10`** Size of the stack of frames to extract activations from (for temporal frames only)  

**`ReduceDimensionality=True`** Option to reduce the dimensionality of the features using reconstruction independent component analysis (RICA).  

* For this to be used, a RICA object must be created for the project. The method for doing so is `project.GenerateRICAModel()`  

**`NumDimensions=512`** Dimensionality to reduce the feature set to when generating the RICA model  

**`SamplePoints=1`** Number (if `SamplePoints` >1) or proportion (if `SamplePoints` <=1) of frame features to use in dimensionality reduction

* To expedite the dimensionality reduction computation, we include an option to use only a portion of frames to generate the RICA model
	* If `SamplePoints` > 1, then features from SamplePoints frames are randomly selected and used to fit the model
	* If `SamplePoints` <= 1, then we randomly select`SamplePoints` proportion of all frames in the project for to generate the model   
* *Examples:* `SamplePoints=1000` selects 1000 random frame's features; `SamplePoints=0.5` selects features from half of the frames in the project  

**`IterationLimit=1000`** Maximum number of iterations to fit RICA model.   

## `[Annotations]`
**`ClipLength=60`** Specifies the desired length of each clip in seconds.

* *Note:* the default `ClipLength=60` means that, by default, clips will be one minute in length

<!--

**`Behaviors (key)`**

List of behaviors and corresponding hotkeys for use in the annotator   

Default:

```
  Behaviors (key)
  	- Behavior1 (1)
  	- Behavior2 (2)
```
-->

## `[Classifier]`

**`SequenceLength=450`** Length (in frames) of sequences to be input into RNN.

**`NumberHiddenUnits=64`** Number of hidden units in each layer of the BiLSTM.

**`NumberLayers=2`** Number of BiLSTM layers.

**`DropoutRatio=0.5`** Dropout probability of dropout layers located after each BiLSTM layer.

**`ClassificationLayer=cross-entropy`** Classification loss function to use.

* *Options:*
	* `cross-entropy`: standard cross-entropy loss function
	* `weighted cross-entropy`: cross-entropy loss, where loss is inversely proportional to the incidence of the class

## `[TrainingOptions]`

**`ShowPlots=true`** Whether or not to show training progress plot when training classifier.

**`MiniBatchSize=8`** Minibatch size to use when training the neural network.

**`MaxExpochs=16`** Maximum number of training epochs. 

**`ValidationFreqEpoch=1`** How often (in epochs) to evaluate the network using the validation data   

**`ValidationPatience=2`** Number of times the loss on the validation set can be larger than or equal to the smallest previous loss training is terminated   

**`InitialLearningRate=0.001`** Initial learning rate when training.

**`LearningRateDropPeriod=4`** Number of epochs before the learning rate drops by`LearningRateDropFactor`. 

**`LearningRateDropFactor=0.1`** Factor by which the learning rate drops after`LearningRateDropPeriod` epochs. 
 
## `[Evaluation]`

**`PredictionMiniBatchSize=256`** Minibatch size to use when generating predictions.

### Train/Validate/Test sets
***Note:*** `TrainProportion` + `ValidationProportion` + `TestProportion` must be <= 1.

**`TrainProportion=0.50`** Proportion of labeled data used to train the classifier.

**`ValidationProportion=0.20`** Proportion of labeled data used to evaluate the classifier (for early termination of classifier to prevent overfitting). 

* *Note:* If `ValidationProportion=0`, no validation set is used.

**`TestProportion=0.30`** Proportion of labeled data used to test the classifier.

## `[ConfidenceScoring]`

**`ScoringMethod='TemperatureScaling'`** Method to use when generating confidence scores.

* *Options:*
	* `TemperatureScaling`: uses temperature scaling-derived confidence score
	* `MaxSoftmax`: uses max softmax probability to create confidence score




