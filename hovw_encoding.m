% HOVW_ENCODING: Histogram of Visual Words script. Creates histograms with
% codebook entries (visual words) frequencies by leaving one of the passes
% out.

% CONSTANT PARAMETERS

FEAT_TYPE = 'SIFT'; % SIFT, DSIFT, SF_GABOR, ST_GABOR, ST_GAUSS,
NUM_WORDS = 400;
ENCODING  = 'VLAD'; % 'HA', 'VLAD'
DESC_PATH = './descriptors';
DICT_PATH = './dictionaries/%d';
CORRIDORS = 1:6;
PASSES    = 1:10;
SELECTOR  = 1:10; % Leave one out strategy pass selector.

% Path strings, modify if NOT using the default suggested paths.

desc_str  = 'C%dP%d_Descriptors.mat';
dict_str  = 'dictionary_C%d_P%s.mat';
dict_path = sprintf(DICT_PATH,NUM_WORDS);

% Main encoding loop

for corr = CORRIDORS
    
    for sel = SELECTOR
        
        c = ['C' num2str(corr)]; % corridor string
        
        training_set = PASSES;
        training_set(sel) = [];
        
        % Construct dictionary path and load vocabulary.
        dictionaries_path = fullfile(dict_path,FEAT_TYPE,c);
        
        training_set_str = sprintf('%d',training_set);
        dict_fname_str = sprintf(dict_str,corr,training_set_str);
        
        load(fullfile(dictionaries_path,dict_fname_str)); % Load VWords
        
        % Load query descriptors
        
        for pass = PASSES
            
            p = ['P' num2str(pass)]; % pass string
            
            descriptors_path = fullfile(DESC_PATH,FEAT_TYPE,c,p);
            
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
            
            if strcmpi(FEAT_TYPE,'SIFT')
                fun_str = ['encode_hovw_' ENCODING '_sparse(VWords,DescriptorStack)'];
                HoVW = eval(fun_str);
            else
                fun_str = ['encode_hovw_' ENCODING '(VWords,DescriptorStack)'];
                HoVW = eval(fun_str);
            end
            
            
            write_path = fullfile(dictionaries_path,...
                ['hovw_' ENCODING '_' c '_P' training_set_str '_' num2str(pass) '.mat']);
            save(write_path,'HoVW');
            
            disp( ['Pass ' p]);
            
        end % end pass for loop
        disp(['All passes encoded for dictionary ' training_set_str]);
    end % end selector for loop
    disp(['Corridor ' c]);
    
end % end corridor for loop
