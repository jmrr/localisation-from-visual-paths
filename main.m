% MAIN is the main script

% Author: Jose Rivera-Rubio
%          {jose.rivera}@imperial.ac.uk
% Date: November, 2014


%% Parameter variables. Change these values HERE

params = struct(...
    'descriptor',    'SF_GABOR',...  % SIFT, DSIFT, SF_GABOR, ST_GABOR, ST_GAUSS,
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

%% Run setup
setup

%% Compute the descriptors given the parameters

computeDescriptors(params);

%% CreateDictionaries (k-means vector quantization)

createDictionaries(params, params.trainingSet);

%% hovwEncoding (Hard assigment, VLAD, or LLC)

if length(params.corridors) > 1
   batchEncoding(params);
else
   encoding(params);       
end

%% kernels for histograms

if (isempty(params.trainingSet))
    if (strcmp(params.kernel,'chi2'))
        run_kernel_HA(params);
    else
        run_kernel_Hellinger(params);
    end
else
    run_kernel_HA_custom(params, params.trainingSet)
end

%% Run evaluation routine to add the error measurement to the kernels.
run_evaluation_nn_VW(params);

%% Generate PDF results

results_generation