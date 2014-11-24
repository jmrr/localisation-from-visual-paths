% RESULTS_GENERATION is the script that given a path with the results of
% the descriptor matching select random queries to compute probability
% density functions (PDFs) and cumulative distribution functions (CDFs).
% These metrics help to generate the plots for comparative studies.
%
% Variables to set:
%   results_path: path where the results are stored.
%   MAX_ERROR: error in cm that is considered as maximum, or too large.
%   This is for visualisation purposes.
%   NUM_RUNS: number of runs.
%   NUM_SAMPLES: from all the results, how many samples to draw.
%
%   Author: Jose M. Rivera-Rubio (2013)

%% VARIABLES TO SET

results_path_str = '/media/Data/Code/Jose/localisation_from_visual_paths/kernels/%s/all_chi2'; %'/media/bg-PictureThis/CODE/ICPR2014/sequence_descriptors/ResultsKernels/HELLINGER';

results_path = sprintf(results_path_str,params.descriptor);

MAX_ERROR = 5000; % 50 metres

NUM_RUNS = 1000;
NUM_SAMPLES = 10000;

pdf = [];

D = dir(results_path);  
D = D(3:end);

num_files = length(D);

error_all = [];

for idx_files = 1:num_files
    
    % Result file path and filename for parsing
    results_file = fullfile(results_path,D(idx_files).name);
    load(results_file);
    % Create the big error structure appending unravelled errors
    error_all = [error_all ; error_in_cm(:)];

end

pdf = randomSampling(error_all,NUM_RUNS,NUM_SAMPLES,MAX_ERROR);

%% Plots

% pdf
mean_pdf = mean(pdf,1);
max_val = max(pdf,[],1);
min_val = min(pdf,[],1);
figure;
plotMaxMinOverGraph(mean_pdf,max_val,min_val,'blue','-','red','-',0.3)

%% cdf
cdf = cumsum(pdf,2);
mean_cdf = mean(cdf,1);
max_val = max(cdf,[],1);
min_val = min(cdf,[],1);
figure;
plotMaxMinOverGraph(mean_cdf,max_val,min_val,'blue','-','red','-',0.3)
