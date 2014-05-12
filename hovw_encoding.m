% HOVW_ENCODING: Histogram of Visual Words script. Creates histograms with
% codebook entries (visual words) frequencies by leaving one of the passes
% out.

feature_type = 'DSIFT';

dict_location = './dictionaries'; % './dictionaries/256' for VLAD-ready dicts

CORRIDORS = 1:6;

PASSES = 1:10;

ENCODING_METHOD = 'HA'; % 'HA', 'VLAD'

SELECTOR = 1:10; % Leave one out strategy pass selector. 

desc_str = 'C%dP%d_Descriptors.mat';

dict_str = 'dictionary_C%d_P%s.mat';

% Main encoding loop

for corr = CORRIDORS

    for sel = SELECTOR
            
        c = ['C' num2str(corr)]; % corridor string
        
        training_set = PASSES;
        training_set(sel) = [];
        
        % Construct dictionary path and load vocabulary.
        dictionaries_path = fullfile(dict_location,feature_type,c);
        
        training_set_str = sprintf('%d',training_set);
        dict_fname_str = sprintf(dict_str,corr,training_set_str);
        
        load(fullfile(dictionaries_path,dict_fname_str)); % Load VWords
        
        % Load query descriptors
        
        for pass = PASSES
            
            p = ['P' num2str(pass)]; % pass string       

            descriptors_path = fullfile('./descriptors',feature_type,c,p);

            descriptors_fname_str = sprintf(desc_str,corr,pass);
            
            while true
                try                
                    load(fullfile(descriptors_path,descriptors_fname_str)); % Load DescriptorStack
                    break
                catch
                    fail_msg = ['Failed to load descriptor ' c p];
                    disp(fail_msg);
                end % end try/catch
            end
            % Encode descriptors with dictionary: vector quantisation
            
            if strcmpi(feature_type,'SIFT')
                HoVW = encode_hovw_HA_sparse(VWords,DescriptorStack);
            else
                HoVW = encode_hovw_HA(VWords,DescriptorStack);
            end


            write_path = fullfile(dictionaries_path,...
                ['hovw_HA_' c '_P' training_set_str '_' num2str(pass) '.mat']);
            save(write_path,'HoVW');

            disp( ['Pass ' p]);
            
        end % end pass for loop
        disp(['All passes encoded for dictionary ' training_set_str]);
    end % end selector for loop
    disp(['Corridor ' c]);

end % end corridor for loop


% function Kernel=EuSims(Descriptors,VWords)
% 
% t1 = sum(Descriptors.^2,2) * (zeros(1,size(VWords,2))+1) ;
% 
% t2 = (zeros(size(Descriptors,1),1)+1) * sum(VWords.^2,1);
% 
% Kernel =sqrt( t1 + t2 -2*Descriptors*VWords ); 