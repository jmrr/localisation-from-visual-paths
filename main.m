% MAIN is the main script

% Author: Jose Rivera-Rubio
%          {jose.rivera}@imperial.ac.uk
%
% Initial version: April, 2014
% First release: November, 2014
% Last Modified: Otober, 2015


%% Run parameters
try
initialize_vMini
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

%% debugging by analysing kernel structure
if (params.debug)
    load('/data/datasets/RSMmini/kernels/HA/CRBML1/C2/C2_kernel_HA_chi2_P12_1.mat')
    figure
    imagesc(Kernel{1})
    title('training passes 1 and 2, query with P1 retrieving with P1')
    %%
    load('/data/datasets/RSMmini/kernels/HA/CRBML1/C2/C2_kernel_HA_chi2_P12_3.mat')
    figure
    imagesc(Kernel{1})   
    title('training passes 1 and 2, query with P3 retrieving with P1')
    figure
    imagesc(Kernel{2})
    title('training passes 1 and 2, query with P3 retrieving with P2')
end
%% Run evaluation routine to add the error measurement to the kernels.
% run_evaluation_nn_VW(params);

%% Generate PDF results

% results_generation