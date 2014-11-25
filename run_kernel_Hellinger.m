function [] = run_kernel_Hellinger(params)
% RUN_KERNEL_HELLINGER constructs the kernel based on the Hellinger
% distance

% Authors: Jose Rivera-Rubio and Ioannis Alexiou 
%          {jose.rivera,ia2109}@imperial.ac.uk
% Date: April, 2014

% Path strings, modify if NOT using the default suggested paths.
hovw_str    = 'hovw_%s_C%d_P%s_%d.mat';
kernel_str  = 'C%d_kernel_%s_%s_P%s_%d.mat';
dict_path   = fullfile(params.dictPath,num2str(params.dictionarySize));
kernel_path = fullfile(params.kernelPath,num2str(params.encoding));

% Anonymous function for the Hellinger Kernel

Whiten=@(Vector)sign(Vector ).*  sqrt(abs(Vector));

for corr = params.corridors

    for pass = params.passes
            
        c = ['C' num2str(corr)]; % corridor string
        p = ['P' num2str(pass)]; % pass string       
        
        training_set = params.passes;
        training_set(pass) = [];
        
        % Construct dictionary path and load encoded pass.
        dictionaries_path = fullfile(dict_path,params.descriptor,c);
        
        training_set_str = sprintf('%d',training_set);
        hovw_fname_str = sprintf(hovw_str,params.encoding,corr,training_set_str,pass);
        
        load(fullfile(dictionaries_path,hovw_fname_str)); % Load VWords
        
        % Normalize the HOVW
        stack_q = Whiten( HoVW );

        stack_q = stack_q./repmat(sqrt(sum(stack_q.^2,2))+eps,[1,size(stack_q,2)]);
          
        % Generate the kernel of distances to the other passes
        idx =  1;

        for db = training_set
            
            % Construct dictionary path and load encoded pass.

            dictionaries_path = fullfile(dict_path,params.descriptor,c);
            hovw_fname_str = sprintf(hovw_str,params.encoding,corr,training_set_str,db);

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

        save_path = fullfile(kernel_path,params.descriptor,c);

        mkdir(save_path);
        warning('off');
        
        kernel_fname_str = sprintf(kernel_str,corr,params.encoding,params.kernel,training_set_str,pass);

        save(fullfile(save_path,kernel_fname_str),'Kernel');
        
        clear Kernel;
        
        disp(['Finished encoding pass ' p]);
    end
    fprintf('VLAD encoding with Hellinger kernel done for corridor %s.\n',c);
    warning('on');
end
