This is a Matlab code to extract visual descriptors and implement a bag of
visual words pipeline from video sequences.
The code is customised and ready to be used with the RSM dataset 
(http://rsm.bicv.org) but can be used on any sort of image sequences if the
directory paths are correctly specified.

Current implemented descriptor extraction methods (description below):
LW_COLOR, SIFT, DSIFT, SF_GABOR, ST_GABOR, ST_GAUSS

Current supported format of the sequences: JPG

Authors: 

*          Jose Rivera (jose.rivera@imperial.ac.uk)
*          Ioannis Alexiou (i.alexiou@qmul.ac.uk)
*          Anil A. Bharath (a.bharath@imperial.ac.uk)

Web: [http://www.bicv.org](http://www.bicv.org)

Date: v4.0 10/2015

Requirements:
============

SIFT, DSIFT, VLAD and kernel implementations require VLFEAT (http://www.vlfeat.org/)
Clustering requires INRIA's Yael K-means (https://gforge.inria.fr/projects/yael/)

Running Instructions:
====================

Rename `initialize.m.template` to `initialize.m`

```
cp initialize.m.template initialize.m
```

Run main.m 

```
#!matlab

main
```

Detailed Instructions:
=====================

Parameter selection
-------------------

*  Dependency paths: include the paths to the dependencies.
- `YAEL`: https://gforge.inria.fr/projects/yael/
- `VLFEAT`: http://www.vlfeat.org/

A version of these libraries is included in the Downloads section of the repository


*  Parameter selection.

Select your choice from the following parameters in the params structure before continuing:


```
#!matlab

params = struct(...
    'descriptor',    'ST_GAUSS',...  % SIFT, DSIFT, SF_GABOR, ST_GABOR, ST_GAUSS,
    'corridors',     1:6,... % Corridors to run [1:6] (RSM v6.0)
    'passes',        1:10,... % Passes to run [1:10] (RSM v6.0)
    'trainingSet',   [1:3,5], ... 
    'datasetDir',    '/data/datasets/RSM/visual_paths/v6.0',...   % The root path of the RSM dataset
    'frameDir',      'frames_resized_w208p',... % Folder name where all the frames have been extracted.
    'descrDir',  ...
    '/data/datasets/RSM/descriptors', ...
    'dictionarySize', 400, ...
    'dictPath',       '/data/datasets/RSM/dictionaries', ...
    'encoding', 'HA', ... % 'HA', 'VLAD', 'LLC'
    'kernel', 'chi2', ... % 'chi2', 'Hellinger'
    'kernelPath', '/data/datasets/RSM/kernels', ...
    'metric', 'max', ...
    'groundTruthPath', './ground_truth', ...
    'debug', 1 ... % 1 shows waitbars, 0 does not.
    );

```

These parameters are the following

* datasetDir: The root path of the RSM dataset
* corridors: Corridors to run [1:6] (RSM v6.0)
* passes: Passes to run [1:10] (RSM v6.0)
* trainingSet: training set to use for dictionary construction
* frameDir: Folder name where all the frames have been extracted.
* descrDir
* descriptor: Type of descriptors to be calculated. To choose from
     - LW_COLOR: Lightweight spatio-temporal colour descriptor
     - SIFT: keypoint based SIFT descriptors
     - DSIFT: Dense SIFT
     - SF_GABOR: Frame-based DAISY-like descriptors
     - ST_GABOR: Spatio-temporal Gabors.
     - ST_GAUSS: Spatio-temporal, Spatial Derivative, Temporal Gaussian
* dictionarySize: number of visual words (parameter k in k-means)
* dictPath: directory where to store the created dictionaries.
* encoding: encoding method
* kernel:
* kernelPath:
* metric:
* groundTruthPath:
* debug:

Descriptor generation
---------------------


```
#!matlab

computeDescriptors(params);

```
Bag of Words pipeline
---------------------

* create_dictionaries (k-means vector quantization)
   
```
#!matlab

cluster_descriptors

% OR

cluster_descriptors_sparse (for Keypoint-SIFT)
```


* hovw_encoding (Hard assigment, VLAD, or LLC)
    
```
#!matlab

hovw_encoding

%       Remember to modify the parameters of the encoding, which will automatically call
%       encode_hovw_METHOD/encode_hovw_METHOD_sparse (for Keypoint-SIFT),
%       where METHOD = 
%         HA, "Visual categorization with bags of keypoints", Dance et al., 2004,
%         VLAD, "Aggregating local descriptors into a compact image representation", Jegou et al., 2010,
%         LLC, "Locality-constrained Linear Coding for Image Classification", Wang et al., 2010.

```
* Kernels for histograms
    
```
#!matlab

run_kernel_HA

% OR

run_kernel_Hellinger

```

* Run evaluation routine to add the error measurement to the kernels.

```
#!matlab
run_evaluation_nn_VW
```

* [Optional: Move kernels to one folder]

```
#!bash
cd /folder/to/kernels
mkdir all_chi2
find . -name *chi2*.mat -exec cp -vf {} all_chi2/ \; # if chi2 kernel
mkdir all_Hellinger
find . -name *Hellinger*.mat -exec cp -vf {} all_chi2/ \;
```


* Generate PDF results and plots with 

```
#!matlab
results_generation.m
```
