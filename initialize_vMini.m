%%INITIALIZE.m Change initialize.m.template remove .template to make it
%%work otherwise main.m will throw an error.

params = struct(...
    'descriptor',    'CRBML1',...  % SIFT, DSIFT, SF_GABOR, ST_GABOR, ST_GAUSS,
    'corridors',     1:3,... % Corridors to run [1:6] (RSM v6.0)
    'passes',        1:3,... % Passes to run [1:10] (RSM v6.0) [0:6] for C0 of v7.0 *Synthetic
    'trainingSet',   [1:2], ... 
    'datasetDir',    '/data/datasets/RSMmini/visual_paths/vMini',...   % The root path of the RSM dataset
    'frameDir',      'frames_resized_w208p',... % Folder name where all the frames have been extracted.
    ...                                         % frames_resized    
    'descrDir',  ...
    '/data/datasets/RSMmini/descriptors', ...
    'dictionarySize', 400, ...
    'dictPath',       '/data/datasets/RSMmini/dictionaries', ...
    'encoding', 'HA', ... % 'HA', 'VLAD', 'LLC'
    'kernel', 'chi2', ... % 'chi2', 'Hellinger'
    'kernelPath', '/data/datasets/RSMmini/kernels', ...
    'metric', 'max', ...
    'groundTruthPath', '/data/datasets/RSMmini/visual_paths/vMini/ground_truth', ...
    'debug', 1 ... % 1 shows waitbars, 0 does not.
    );

% SETUP adds the paths for the necessary 3rd party libraries
 
addpath('/data/users/jmr10/yael');
addpath('/data/users/jmr10/vlfeat-0.9.20/toolbox');
vl_setup