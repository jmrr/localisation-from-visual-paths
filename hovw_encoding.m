% function encode_hovw_HA(feature_type)

feature_type = 'ST_GAUSS';

CORRIDORS = 1:6;

PASSES = 1:10;

desc_str = 'C%dP%d_Descriptors.mat';

dict_str = 'dictionary_C%d_P%s.mat';

for corr = CORRIDORS

    for pass = PASSES
            
        c = ['C' num2str(corr)]; % corridor string
        p = ['P' num2str(pass)]; % pass string       
        
        training_set = PASSES;
        training_set(pass) = [];
        
        % Construct dictionary path and load vocabulary.
        dictionaries_path = fullfile('./dictionaries',feature_type,c);
        
        training_set_str = sprintf('%d',training_set);
        dict_fname_str = sprintf(dict_str,corr,training_set_str);
        
        load(fullfile(dictionaries_path,dict_fname_str)); % Load VWords
        
        % Load query descriptors
        
        descriptors_path = fullfile('./descriptors',feature_type,c,p);
        
        descriptors_fname_str = sprintf(desc_str,corr,pass);
        
        load(fullfile(descriptors_path,descriptors_fname_str)); % Load DescriptorStack
                
        % Encode descriptors with dictionary: vector quantisation
        
        HoVW = encode_hovw_HA(VWords,DescriptorStack);
        
        write_path = fullfile(dictionaries_path,...
            ['hovw_' c '_P' training_set_str '_' num2str(pass) '.mat']);
        save(write_path,'HoVW');
        
        disp( ['Pass' p]);

    end % end pass for loop

    disp(['Corridor' c]);
end % end corridor for loop


% function Kernel=EuSims(Descriptors,VWords)
% 
% t1 = sum(Descriptors.^2,2) * (zeros(1,size(VWords,2))+1) ;
% 
% t2 = (zeros(size(Descriptors,1),1)+1) * sum(VWords.^2,1);
% 
% Kernel =sqrt( t1 + t2 -2*Descriptors*VWords ); 