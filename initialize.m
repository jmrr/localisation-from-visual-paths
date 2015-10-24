%%INITIALIZE.m Change initialize.m.template remove .template to make it
%%work

%% Parameter variables. Change these values HERE

params = struct(...
    'descriptor',    'SF_GABOR',...  % SIFT, DSIFT, SF_GABOR, ST_GABOR, ST_GAUSS,
    'corridors',     0,... % Corridors to run [1:6] (RSM v6.0)
    'passes',        0:6,... % Passes to run [1:10] (RSM v6.0)
    'trainingSet',   [1:3,5], ... % Comment out for Leave one out
    'datasetDir',    '/home/jose/PhD/Data/VISUAL_PATHS/PseudoCorridor',...   % The root path of the RSM dataset
    'frameDir',      'frames_resized_200x150',... % Folder name where all the frames have been extracted.
    'descrDir',  ...
    'descriptors', ...
    'dictionarySize', 400, ...
    'dictPath',       'dictionaries', ...
    'encoding', 'HA', ... % 'HA', 'VLAD', 'LLC'
    'kernel', 'HA', ... % 'chi2', 'Hellinger'
    'kernelPath', 'kernels', ...
    'metric', 'max', ...
    'groundTruthPath', './ground_truth', ...
    'debug', 1 ... % 1 shows waitbars, 0 does not.
    );


% SETUP adds the paths for the necessary 3rd party libraries

addpath('/home/jose/Applications/yael_matlab_linux64_v401');
addpath('/home/jose/Applications/vlfeat-0.9.20/toolbox');
vl_setup;