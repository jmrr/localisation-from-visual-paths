function run_evaluation_nn_VW(params)

% Path strings, modify if NOT using the default suggested paths.

kernel_path = sprintf(params.kernelPath,params.encoding);

for corr = params.corridors
    
    c = ['C' num2str(corr)]; % corridor string
    
    kernel_results_path = fullfile(kernel_path,feature_type,c);
    
    evaluation_nn_VW(kernel_results_path,params.groundTruthPath,params.metric,DEBUG)
    
    fprintf('Evaluation finished for corridor %d:\n',corr);
    
end % end for loop

corridor_str = sprintf('%d',params.corridors);

fprintf('Ground truth evaluation generated for corridors %s and feature type %s :)\n',corridor_str,feature_type);

end %end run_evaluation_nn_VW