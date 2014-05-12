function [] = run_kernel_HA

%% PARAMETERS %%

feature_type = 'ST_GAUSS';

CORRIDORS = 1:6;

PASSES = 1:10;

DICT_PATH = './dictionaries';

KERNEL_PATH = './kernels';

hovw_str = 'hovw_HA_C%d_P%s_%d.mat';

kernel_str = 'C%d_kernel_HA_chi2_P%s_%d.mat';

% END OF PARAMETERS

for corr = CORRIDORS

    for pass = PASSES
            
        c = ['C' num2str(corr)]; % corridor string
        p = ['P' num2str(pass)]; % pass string       
        
        training_set = PASSES;
        training_set(pass) = [];
        
        % Construct dictionary path and load encoded pass.
        dictionaries_path = fullfile(DICT_PATH,feature_type,c);
        
        training_set_str = sprintf('%d',training_set);
        hovw_fname_str = sprintf(hovw_str,corr,training_set_str,pass);
        
        load(fullfile(dictionaries_path,hovw_fname_str)); % Load VWords
        
        % Normalize the HOVW
        
        stack_q = HoVW./repmat(sqrt(sum(HoVW.^2,2))+eps,[1,size(HoVW,2)]);
        
        stack_q = vl_homkermap(stack_q',1,'kchi2');
        
        % Generate the kernel of distances to the other passes
        idx =  1;

        for db = training_set
            
            % Construct dictionary path and load encoded pass.
            hovw_str_regexp = 'hovw_HA_C%d_P*_%d.mat';

            dictionaries_path = fullfile('./dictionaries',feature_type,c);
            hovw_fname_str = sprintf(hovw_str,corr,training_set_str,db);

            curr_db_file = dir(fullfile(dictionaries_path,hovw_fname_str));

            load(fullfile(dictionaries_path,curr_db_file(1).name)); % Load encoded db pass

            % Normalise and stack

            stack_db = HoVW./repmat(sqrt(sum(HoVW.^2,2))+eps,[1,size(HoVW,2)]);

            stack_db = vl_homkermap(stack_db',1,'kchi2');

            % Construct Chi2 kernel

            Kernel(idx) = {stack_q'*stack_db};
            
            idx = idx+1;         
 
        end
        
        % Save kernel

        save_path = fullfile(KERNEL_PATH,feature_type,c);

        mkdir(save_path);
        warning('off','last');
        
        kernel_fname_str = sprintf(kernel_str,corr,training_set_str,pass);

        save(fullfile(save_path,kernel_fname_str),'Kernel');
        
        clear Kernel;
        
        disp(['Finished encoding pass ' p]);
    end
    fprintf('Hard assignment encoding done for corridor %s.\n',c);
end
