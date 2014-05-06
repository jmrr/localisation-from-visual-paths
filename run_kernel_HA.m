function Kernel = run_kernel_HA

%% PARAMETERS %%

feature_type = 'DSIFT';

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

%             hovw_fname_str = sprintf(hovw_str_regexp,corr,db);

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

    end
end




% featype='SIFT';
% 
% for corridor=1:6
% 
% path=fullfile(pwd,['Cor',num2str(corridor)],featype);
% 
% % files=dir(fullfile(path, '*_Descriptors.mat'));
% 
% for com=6%1:5
%     
% selector=1:5;
% % selector(com)=[];
% 
% % name = num2str(1000*selector(1)+100*selector(2)+10*selector(3)+selector(4));
% name = num2str(10000*selector(1)+1000*selector(2)+100*selector(3)+10*selector(4)+selector(5));
% 
% 
% % FileName=['Cor',num2str(corridor),'-Pass*.mat'];
% 
% FileQuery=['Cor',num2str(corridor),'-Pass',num2str(com),'_HistHA_',name,'_',num2str(com),'.mat'];
% 
% load(fullfile(path,FileQuery))
% 
% % need to normalize
% 
% Stack_Q = HoVW_Layer1 ./ repmat(sqrt(sum(HoVW_Layer1.^2,2))+eps,1,size(HoVW_Layer1,2));
% 
% Stack_Q = vl_homkermap( Stack_Q', 1, 'kchi2')';
% 
% for i=1:5%:4
% 
% read = fullfile(path,['Cor',num2str(corridor),'-Pass',num2str(selector(i)),'_HistHA_' name '_' num2str(selector(i)) '.mat']);
% 
% load(read); Stack_T = HoVW_Layer1 ./ repmat(sqrt(sum(HoVW_Layer1.^2,2))+eps,1,size(HoVW_Layer1,2));
% 
% Stack_T = vl_homkermap( Stack_T', 1, 'kchi2')';
% 
% Kernel(i) = {Stack_Q*Stack_T'};
% 
% end
% 
% write = fullfile(path,['Cor',num2str(corridor),'_KenrelChi2_' name '_' num2str(com) '.mat']);
% save(write,'Kernel','-v7.3')
% 
% disp(['PermSamples' num2str(name)])
% end
% disp(['Corridor' num2str(corridor)])
% end
