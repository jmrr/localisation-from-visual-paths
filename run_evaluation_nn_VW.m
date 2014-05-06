feature_type = 'SF_GABOR';

CORRIDORS = 1:6;

KERNEL_PATH = './kernels';

GROUND_TRUTH_PATH = '/media/bg-PictureThis/VISUAL_PATHS/v5.0/ground_truth';

METRIC = 'max';


for corr = CORRIDORS
    
    c = ['C' num2str(corr)]; % corridor string

    results_path = fullfile(KERNEL_PATH,feature_type,c);
    
    evaluation_nn_VW(results_path,GROUND_TRUTH_PATH,METRIC)
    
end % end for loop

corridor_str = sprintf('%d',CORRIDORS);

fprintf('Ground truth evaluation generated for corridors %s and feature type %s :)\n',corridor_str,feature_type);

