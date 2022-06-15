#  DeepAction configuration files


Below is descriptions for the parameters specified in the DeepAction project configuration file (`config.txt`).


## Project


<details>
<summary> `ProjectName` </summary>
<p>
Name of the project, as derived from the project path used to instantiate the object

* Not editable (i.e., to change the project, rename the project folder and the `ProjectName` will be updated automatically)

---
</p>
</details>


<details>
<summary> `MultipleCameras=false ` </summary>
<p>
Option to use multiple cameras

Default: `false`

---
</p>
</details>


<details>
<summary> `CameraNames=[]` </summary>
<p>
Camera names, in the event of multiple-camera integration

* Must be specified if `MultipleCameras=true`, otherwise ignored
* Specified as an array of characters (e.g., `CameraNames=[cam1, cam2, cam3]`)

Default: `[]`

---
</p>
</details>


<details>
<summary> `PrimaryCamera='' ` </summary>
<p>
In the case of multiple camera projects, the primary camera is used for annotation, creation of labeled clips, etc.

Default: `''`

---
</p>
</details>


<details>
<summary> `VerboseLevel=3 ` </summary>
<p>
Description

Default: 3

---
</p>
</details>


  
## Stream
===========


<details>
<summary> `ImageType=image ` </summary>
<p>
Specifies the format for storing extracted spatial and temporal frames   

* `ImageType=image` stores as images with extension ImageExtension  
* `ImageType=video` stores as videos with extension ImageExtension
* `ImageType=sequence` stores the extracted from as sequence files

Default: `ImageType=image`

---
</p>
</details>



<details>
<summary> `ImageExtension='.png' ` </summary>
<p>
Extension to use for storing extracted frames   

* Options: 
	* If `ImageType=image`: `'.png'` or `='.jpg'`
	* if `ImageType=video`: `'.mp4'` or `'.avi'`
	* if `ImageType=sequence`: ignored, and uses `'.seq'` extension

Default: `'.png'`

---
</p>
</details>



<details>
<summary> `SpatialStream=true ` </summary>
<p>
Specifies whether to use/create the spatial stream (in generating frames, creating features, and training the classifier)   

Default: `true`

---
</p>
</details>



<details>
<summary> `TemporalStream=true ` </summary>
<p>
Specifies whether to use/create the temporal stream (in generating frames, creating features, and training the classifier) 

Default: `TemporalStream=true`

---
</p>
</details>



<details>
<summary> `Method=Farneback ` </summary>
<p>
Method to use to estimate the optical flow between images  

* Options:
	* `TV-L1`: uses TV-L1 estimation  
	* `Farneback`: uses the Farneback method, as is substantially faster than TV-L1  

Default: `Method=Farneback`

---
</p>
</details>

<details>
<summary> `ResizeFlow=true ` </summary>
<p>
Option to downsize the images before estimating the optical flow, which decreases runtime   

* If `ResizeFlow=True`, the size of the downsampled images must be specified by `FlowImageSize`  

Default: `ResizeFlow=true`

---
</p>
</details>




<details>
<summary> `FlowImageSize=[224, 224]` </summary>
<p>
Size of images used for optical flow estimation (`[numrows, numcols]`)

Default: `FlowImageSize=[224, 224]` (which is the input size of the ResNet18 network)

---
</p>
</details>




<details>
<summary> `ReduceDimensionality=True` </summary>
<p>
Option to reduce the dimensionality of the features using reconstruction independent component analysis (RICA).  

* For this to be used, a RICA object must be created for the project. The method for doing so is `project.GenerateRICAModel()`  

Default: `ReduceDimensionality=True`  

---
</p>
</details>



<details>
<summary> `NumDimensions=512` </summary>
<p>
Dimensionality to reduce the feature set to when generating the RICA model  

Default: `NumDimensions=512`

---
</p>
</details>



<details>
<summary> `SamplePoints=1`</summary>
<p>
Number (if `SamplePoints`>1) or proportion (if `SamplePoints`<=1) of frame features to use in dimensionality reduction

* To expedite the dimensionality reduction computation, we include an option to use only a portion of frames to generate the RICA model
	* If `SamplePoints` > 1, then features from SamplePoints frames are randomly selected and used to fit the model
	* If `SamplePoints` <= 1, then we randomly select `SamplePoints` proportion of all frames in the project for to generate the model   
* Examples: `SamplePoints=1000` selects 1000 random frame's features; `SamplePoints=0.5` selects features from half of the frames in the project  

Default: `1`

---
</p>
</details>



<details>
<summary>  `IterationLimit=1000`</summary>
<p>
Maximum number of iterations to fit RICA model.  

Default: 1000

---
</p>
</details>



## Features
<details>
<summary>`FeatureExtractor=ResNet18`  </summary>
<p>
Pretrained CNN to use in extracting features from video frames

* Options: `ResNet18`, `ResNet50`, `GoogLeNet`, `VGG-16`, `VGG-19`, `InceptionResNetv2`

Default: `FeatureExtractor=ResNet18`

---
</p>
</details>



<details>
<summary> `CNNMiniBatchSize=128`  </summary>
<p>
Batch size to use when extracting activations from the CNN

Default: `128`

---
</p>
</details>



<details>
<summary> `FlowStackSize=10` </summary>
<p>
Size of the stack of frames to extract activations from (for temporal frames only)   

Default: `10`

---
</p>
</details>



## Annotations
<details>
<summary>`ClipLength=60`   </summary>
<p>
Specifies the desired length of each clip in seconds.

Default: `60` (each clip will be ~1 minute long)

---
</p>
</details>

<!--

<details>
<summary> `Behaviors (key)`</summary>
<p>
List of behaviors and corresponding hotkeys for use in the annotator   

Default:

```
  Behaviors (key)
  	- Behavior1 (1)
  	- Behavior2 (2)
```

---
</p>
</details>
-->

## Classifier

<details>
<summary> `SequenceLength=450` </summary>
<p>
Length (in frames) of sequences to be input into RNN.

Default: `450`

---
</p>
</details>

<details>
<summary> `NumberHiddenUnits=64` </summary>
<p>
Number of hidden units in each layer of the BiLSTM.

Default: `64`

---
</p>
</details>



<details>
<summary> `NumberLayers=2` </summary>
<p>
Number of BiLSTM layers.

Default: `2`

---
</p>
</details>



<details>
<summary> `DropoutRatio=0.5`</summary>
<p>
Dropout probability of dropout layers located after each BiLSTM layer.

Default: `0.5`

---
</p>
</details>



<details>
<summary>`ClassificationLayer=cross-entropy`</summary>
<p>
Classification loss function to use.

* Options: 
	* `cross-entropy`: standard cross-entropy loss function
	* `weighted cross-entropy`: cross-entropy loss, where loss is inversely proportional to the incidence of the class

Default: `cross-entropy`	

---
</p>
</details>
 

## TrainingOptions

<details>
<summary> `ShowPlots=true`</summary>
<p>
Whether or not to show training progress plot when training classifier.

Default: `true`

---
</p>
</details>

<details>
<summary> `MiniBatchSize=8`</summary>
<p>
Minibatch size to use when training the neural network.

Default: `8`

---
</p>
</details>


<details>
<summary> `MaxExpochs=16`</summary>
<p>
Maximum number of training epochs. 

Default: `16`

---
</p>
</details>

<details>
<summary> `ValidationFreqEpoch=1`</summary>
<p>
How often (in epochs) to evaluate the network using the validation data   

Default: `1`

---
</p>
</details>



<details>
<summary> `ValidationPatience=2`</summary>
<p>
Number of times the loss on the validation set can be larger than or equal to the smallest previous loss training is terminated   

Default: `2`

---
</p>
</details>


<details>
<summary> `InitialLearningRate=0.001`</summary>
<p>
initial learning rate when training.

Default: `0.001`

---
</p>
</details>


<details>
	<summary> `LearningRateDropPeriod=4`</summary>
<p>
Number of epochs before the learning rate drops by `LearningRateDropFactor`. 

Default: `4`

---
</p>
</details>



<details>
	<summary> `LearningRateDropFactor=0.1`</summary>
<p>
Factor by which the learning rate drops after `LearningRateDropPeriod` epochs. 

Default: `0.1`

---
</p>
</details>

 
## Evaluation

<details>
	<summary> `PredictionMiniBatchSize=256`</summary>
<p>
Minibatch size to use when generating predictions.

Default: `256`

---
</p>
</details>


#### Train/Validate/Test sets
<details>
	<summary> `TrainProportion=0.50`</summary>
<p>
Proportion of labeled data used to train the classifier.

Default: `0.5`

---
</p>
</details>

<details>
	<summary> `ValidationProportion=0.20`</summary>
<p>
Proportion of labeled data used to evaluate the classifier (for early termination of classifier to prevent overfitting). 

* Note: if `ValidationProportion=0`, no validation set is used.

Default: `0.2`

---
</p>
</details>

<details>
	<summary> `TestProportion=0.30`</summary>
<p>
Proportion of labeled data used to test the classifier.

Default: `0.3`

---
</p>
</details>

Note: `TrainProportion` + `ValidationProportion` + `TestProportion` must be <= 1.


## Confidence scoring

<details>
	<summary> `ScoringMethod='TemperatureScaling '`</summary>
<p>
Method to use when generating confidence scores.

* Options:
	* `TemperatureScaling`: uses temperature scaling-derived confidence score
	* `MaxSoftmax`: uses max softmax probability to create confidence score

Default: `0.3`

---
</p>
</details>

