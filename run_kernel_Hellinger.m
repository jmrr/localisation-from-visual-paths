function [] = run_kernel_Hellinger

%% PARAMETERS %%

FEAT_TYPE   = 'ST_GABOR'; % SIFT, DSIFT, SF_GABOR, ST_GABOR, ST_GAUSS,
ENCODING    = 'VLAD'; % 'HA', 'VLAD'
DICT_PATH   = './dictionaries/%d'; 
NUM_WORDS   = 256;
CORRIDORS   = 1:6;
PASSES      = 1:10;
KERNEL_PATH = './kernels/%s';
KERNEL = 'Hellinger';


% Path strings, modify if NOT using the default suggested paths.
hovw_str    = 'hovw_%s_C%d_P%s_%d.mat';
kernel_str  = 'C%d_kernel_%s_%s_P%s_%d.mat';
dict_path   = sprintf(DICT_PATH,NUM_WORDS);
kernel_path = sprintf(KERNEL_PATH,ENCODING);

% Anonymous function for the Hellinger Kernel

Whiten=@(Vector)sign(Vector ).*  sqrt(abs(Vector));

for corr = CORRIDORS

    for pass = PASSES
            
        c = ['C' num2str(corr)]; % corridor string
        p = ['P' num2str(pass)]; % pass string       
        
        training_set = PASSES;
        training_set(pass) = [];
        
        % Construct dictionary path and load encoded pass.
        dictionaries_path = fullfile(dict_path,FEAT_TYPE,c);
        
        training_set_str = sprintf('%d',training_set);
        hovw_fname_str = sprintf(hovw_str,ENCODING,corr,training_set_str,pass);
        
        load(fullfile(dictionaries_path,hovw_fname_str)); % Load VWords
        
        % Normalize the HOVW
        stack_q = Whiten( HoVW );

        stack_q = stack_q./repmat(sqrt(sum(stack_q.^2,2))+eps,[1,size(stack_q,2)]);
          
        % Generate the kernel of distances to the other passes
        idx =  1;

        for db = training_set
            
            % Construct dictionary path and load encoded pass.

            dictionaries_path = fullfile(dict_path,FEAT_TYPE,c);
            hovw_fname_str = sprintf(hovw_str,ENCODING,corr,training_set_str,db);

            curr_db_file = dir(fullfile(dictionaries_path,hovw_fname_str));

            load(fullfile(dictionaries_path,curr_db_file(1).name)); % Load encoded db pass

            % Normalise and stack
            
            stack_db = Whiten(HoVW);

            stack_db = stack_db./repmat(sqrt(sum(stack_db.^2,2))+eps,[1,size(stack_db,2)]);

            % Construct Chi2 kernel

            Kernel(idx) = {stack_q*stack_db'};
            
            idx = idx+1;         
 
        end
        
        % Save kernel

        save_path = fullfile(kernel_path,FEAT_TYPE,c);

        mkdir(save_path);
        warning('off');
        
        kernel_fname_str = sprintf(kernel_str,corr,ENCODING,KERNEL,training_set_str,pass);

        save(fullfile(save_path,kernel_fname_str),'Kernel');
        
        clear Kernel;
        
        disp(['Finished encoding pass ' p]);
    end
    fprintf('VLAD encoding with Hellinger kernel done for corridor %s.\n',c);
    warning('on');
end