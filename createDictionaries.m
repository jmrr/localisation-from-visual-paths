function [] = createDictionaries(params)

% CREATE_DICTIONARIES generates all the combination of passes and calls
% cluster_descriptors to construct bag of visual words (BOVW) dictionaries.
%
% Parameters to select:
%
%   num_words: number of visual words of the dictionary
%

% From the case of all passes contributing to the dictionary to the case of
% only one pass contributing to the dictionary, select all the possible
% combinations.

% For the time being, leave only one out.


dict_path = sprintf(params.dictPath,params.dictionarySize);

for p = params.passes
    
    training_set = params.passes;
    training_set(p) = [];
    if strcmpi(params.descriptor,'SIFT')
        cluster_descriptors_sparse(params.descrDir,params.descriptor,params.corridors,params.dictionarySize,training_set,dict_path)
    else % dense
        cluster_descriptors(params.descrDir,params.descriptor,params.corridors,params.dictionarySize,training_set,dict_path)
    end
end % end for loop

end % end createDictionaries