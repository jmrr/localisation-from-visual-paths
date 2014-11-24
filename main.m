% MAIN

%% Parameter variables. Change these values HERE

params = struct(...
    'descriptor',    'DSIFT',...  % SIFT, DSIFT, SF_GABOR, ST_GABOR, ST_GAUSS,
    'corridors',     1:3,... % Corridors to run [1:6] (RSM v6.0)
    'passes',        1:3,... % Passes to run [1:10] (RSM v6.0)
    'datasetDir',    '/media/PictureThis/VISUAL_PATHS/vMini',...   % The root path of the RSM dataset
    'frameDir',      'frames_resized_w208p',... % Folder name where all the frames have been extracted.
    'descrDir',  ...
    '/media/Data/localisation_from_visual_paths_data/descriptors', ...
    'dictionarySize', 4000, ...
    'dictPath',       './dictionaries/%d', ...
    'encoding', 'LLC', ... % 'HA', 'VLAD'
    'kernel', 'chi2', ... % 'chi2', 'Hellinger'
    'kernelPath', './kernels/%s', ...
    'metric', 'max', ...
    'groundTruthPath', '/media/PictureThis/VISUAL_PATHS/vMini/ground_truth', ...
    'debug', 1 ... % 1 shows waitbars, 0 does not.
    );

%% Run setup
setup

%% Compute the descriptors given the parameters

computeDescriptors(params);

%% Create_dictionaries (k-means vector quantization)

createDictionaries(params);

%% hovw_encoding (Hard assigment, VLAD, or LLC)

hovw_encoding(params);

%% kernels for histograms

if (strcmp(params.kernel,'chi2'))
    run_kernel_HA(params);
else
    run_kernel_Hellinger(params);
end

%% Run evaluation routine to add the error measurement to the kernels.
run_evaluation_nn_VW(params);

% Generate PDF results

results_generation