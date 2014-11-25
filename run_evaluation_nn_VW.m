function run_evaluation_nn_VW(params)
% run_evaluation_nn_VW batch-runs EVALUATION_NN_VW 
% See also private/EVALUATION_NN_VW

% Authors: Jose Rivera-Rubio and Ioannis Alexiou 
%          {jose.rivera,ia2109}@imperial.ac.uk
% Date: November, 2014

% Path strings, modify if NOT using the default suggested paths.

kernel_path = fullfile(params.kernelPath,params.encoding);

for corr = params.corridors
    
    c = ['C' num2str(corr)]; % corridor string
    
    kernel_results_path = fullfile(kernel_path,params.descriptor,c);
    
    evaluation_nn_VW(params, kernel_results_path)
    
    fprintf('Evaluation finished for corridor %d:\n',corr);
    
end % end for loop

corridor_str = sprintf('%d',params.corridors);

fprintf('Ground truth evaluation generated for corridors %s and feature type %s :)\n', ...
    corridor_str,params.descriptor);

end %end run_evaluation_nn_VW