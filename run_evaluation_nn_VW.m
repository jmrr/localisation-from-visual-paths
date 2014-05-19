GROUND_TRUTH_PATH = '/media/bg-PictureThis/VISUAL_PATHS/v5.0/ground_truth';
FEAT_TYPE         = 'ST_GAUSS';
CORRIDORS         = 1:6;
KERNEL_PATH       = './kernels/%s';
ENCODING          = 'HA'; % 'HA', 'VLAD'
METRIC            = 'max';

DEBUG = 0; % 1 shows waitbars, 0 does not.


% Path strings, modify if NOT using the default suggested paths.

kernel_path = sprintf(KERNEL_PATH,ENCODING);

for corr = CORRIDORS
    
    c = ['C' num2str(corr)]; % corridor string

    kernel_results_path = fullfile(kernel_path,feature_type,c);
    
    evaluation_nn_VW(kernel_results_path,GROUND_TRUTH_PATH,METRIC,DEBUG)
    
    fprintf('Evaluation finished for corridor %d:\n',corr);
    
end % end for loop

corridor_str = sprintf('%d',CORRIDORS);

fprintf('Ground truth evaluation generated for corridors %s and feature type %s :)\n',corridor_str,feature_type);

