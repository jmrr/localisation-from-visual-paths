% MAIN is the main script

% Author: Jose Rivera-Rubio
%          {jose.rivera}@imperial.ac.uk
%
% Initial version: April, 2014
% First release: November, 2014
% Last Modified: Otober, 2015


%% Run parameters
try
initialize
catch
    disp('Make sure your initialization script template has been renamed to initialize.m')
end
%% Compute the descriptors given the parameters
tic;
computeDescriptors(params);
disp('Descriptors computed');
toc
%% CreateDictionaries (k-means vector quantization)
tic;
createDictionaries(params, params.trainingSet);
disp('Dictionary created');
toc
%% hovwEncoding (Hard assigment, VLAD, or LLC)
tic;
if length(params.corridors) > 1
    batchEncoding(params);
else
    encoding(params);
end
toc
%% kernels for histograms
tic;
if (strcmp(params.kernel,'chi2'))
    runKernelHA(params);
else
    runKernelHellinger(params);
end
disp('Kernels encoded')
toc
%% Run evaluation routine to add the error measurement to the kernels.
% run_evaluation_nn_VW(params);

%% Generate PDF results

% results_generation