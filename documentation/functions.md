# Functions


## Project constructor
`project = DeepActionProject(projectFolder)`

Initializes a DeepAction project in folder `projectFolder`. 

## Project setup

#### `project.CreateProject()`
Creates a project folder, located at `project.ProjectPath`, and initializes a `config.txt` file with default parameters (see `config_file.md` for details). 


#### `project.ImportVideos(videoImportT)`  
Imports the videos contained in the table `videoImportT` into the project and initializes empty annotation files for them. In the case of single-camera projects, `videoImportT` consists of two columns: `VideoNames` with the names of the videos in each row, and `VideoPath`, with the path to each video. In the case of multiple-camera projects, each column following `VideoNames` corresponds to a single camera's video file, with the column header denoting the camera name. 

####  `project.ImportAnnotations(annotationImportT)`  
If the user has already annotated a subset of video, these annotations can be imported into the project and converted to the DeepAction annotation format. To do so, we specify a table `annotationImportT` with the names (`VideoName`) and paths (`FilePath`) to .csv files containing the annotations to import. The files specified by `FilePath` must have the following format:

| Frame      | behavior1 | behavior2     | behavior3     | 
| ----------- | ----------- | ----------- | ----------- |


where **Frame** denotes the frame number, and behaviors **behavior1**, **behavior2**, **behavior3**, etc. are the behaviors in the dataset (e.g., "eat," "drink," etc.). Each entry in the behavior columns is a 1 or a 0 indicate whether the behavior is (1) or is not (0) occuring in the corresponding frame number in column **Frame**.  

## Generating frames/features

####  `project.GenerateFrames()`  
Generates the spatial and temporal (if specified in `config.txt`) frames. Includes the optional argument `'parallelize'` to parallelize frame extraction (i.e., `project.GenerateFrames('parallelize', true)`). By default, `parallelize` is `false`.


#### `project.ExtractFeatures()`  
`project.ExtractFeatures()`  
Extract features from frames using pretrained CNN feature extractor. Includes the optional argument `'parallelize'` to parallelize frame extraction (default `false`).


#### `project.GenerateRICAModel()`  
`project.GenerateRICAModel()`  
Generates dimensionality reduction model for extracted features using reconstruction independent component analysis. 



## Annotator

#### `project = project.GetAnnotatorData()`  
`project = project.GetAnnotatorData()`  
Sets up project for manual annotation by collecting the available project video.

### `project.LaunchAnnotator();`  
Launches annotator (for initial manual annotations and confidence-based review) using the clips generated for project `project`. Also backs up annotations to `./annotations_backup` subfolder.

## Classifier creation and training

#### `project = project.GetClassifierData()`  
Loads features and annotations used to train the classifier.

#### `project = project.SplitClipData()`  
Splits clip table into train/validation/test sets.

#### `project = project.SetUpClassifier('showplots', true)`  
Creates BiLSTM network used to generate behavior predictions.

#### `project = project.TrainClassifier()`  
Trains classifier and generates predicted behaviors for all project videos.

#### `project.SaveClassifier()`
Saves classifier to the `./classifiers` subfolder in the project folder. You can then use the command `project.LoadClassifier()` to load the most recent saved pre-trained classifier, or `project.LoadClassifier(version)` to load the classifier saved in folder `version`.



## Confidence-based review

`project = project.GenerateConfidenceScores();`  
Trains confidence scorer specified in `config.txt` (either temperature scaling- or max softmax-based) and generates confidence scores for each clip.


## Data export

#### `project.CreateLabeledClips()`
Creates example clips overlaid with model annotations and human labels (if applicable).


#### `project.ExportAnnotations()`  
Exports annotations for each video to `./results/annotations`.






