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
    kernelFname = sprintf('%s/%s/%s/C2/C2_kernel_HA_chi2_P%s_%d.mat',...
        params.kernelPath,params.encoding,params.descriptor,sprintf('%d',params.trainingSet)',...
        params.trainingSet(1));    
    load(kernelFname);
    figure
    imagesc(Kernel{1})
    title(sprintf('training passes %s, query with P%d retrieving with P%d',...
        sprintf('%d',params.trainingSet),params.trainingSet(1),params.trainingSet(1)))
        %%
    qPass = params.passes; qPass(params.trainingSet) = []
    kernelFname = sprintf('%s/%s/%s/C2/C2_kernel_HA_chi2_P%s_%d.mat',...
        params.kernelPath,params.encoding,params.descriptor,sprintf('%d',params.trainingSet),qPass');
    load(kernelFname);
    figure
    imagesc(Kernel{1})   
    title(sprintf('training passes %s, query with P%d retrieving with P%d',...
        sprintf('%d',params.trainingSet),qPass,params.trainingSet(1)))
    figure
    imagesc(Kernel{2})
    title(sprintf('training passes %s, query with P%d retrieving with P%d',...
        sprintf('%d',params.trainingSet),qPass,params.trainingSet(2)))
end
%% Run evaluation routine to add the error measurement to the kernels.
% run_evaluation_nn_VW(params);

%% Generate PDF results

% results_generation