function [] = hovw_encoding(params)
% HOVW_ENCODING Histogram of Visual Words encoding. Creates histograms
% with codebook entries (visual words) frequencies by leaving one of the
% passes out.

% Authors: Jose Rivera-Rubio and Ioannis Alexiou 
%          {jose.rivera,ia2109}@imperial.ac.uk
% Date: November, 2014

% CONSTANT PARAMETERS
selector  = params.passes; % Leave one out strategy pass selector.

% Path strings, modify if NOT using the default suggested paths.

desc_str  = 'C%dP%d_Descriptors.mat';
dict_str  = 'dictionary_C%d_P%s.mat';
dict_path = fullfile(params.dictPath,num2str(params.dictionarySize));

% Main encoding loop

for corr = params.corridors
    
    for sel = selector
        
        c = ['C' num2str(corr)]; % corridor string
        
        training_set = params.passes;
        training_set(sel) = [];
        
        % Construct dictionary path and load vocabulary.
        dictionaries_path = fullfile(dict_path,params.descriptor,c);
        
        training_set_str = sprintf('%d',training_set);
        dict_fname_str = sprintf(dict_str,corr,training_set_str);
        
        load(fullfile(dictionaries_path,dict_fname_str)); % Load VWords
        
        % Load query descriptors
        
        for pass = params.passes
            
            p = ['P' num2str(pass)]; % pass string
            
            descriptors_path = fullfile(params.descrDir,params.descriptor,c,p);
            
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
            
            if strcmpi(params.descriptor,'SIFT')
                fun_str = ['encode_hovw_' params.encoding '_sparse(VWords,DescriptorStack)'];
                HoVW = eval(fun_str);
            else
                fun_str = ['encode_hovw_' params.encoding '(VWords,DescriptorStack)'];
                HoVW = eval(fun_str);
            end
            
            
            write_path = fullfile(dictionaries_path,...
                ['hovw_' params.encoding '_' c '_P' training_set_str '_' num2str(pass) '.mat']);
            save(write_path,'HoVW');
            
            disp( ['Pass ' p]);
            
        end % end pass for loop
        disp(['All passes encoded for dictionary ' training_set_str]);
    end % end selector for loop
    disp(['Corridor ' c]);
    
end % end corridor for loop

end % end hovw_encoding