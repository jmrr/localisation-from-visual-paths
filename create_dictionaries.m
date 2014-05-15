% CREATE_DICTIONARIES generates all the combination of passes and calls
% cluster_descriptors to construct bag of visual words (BOVW) dictionaries.
%
% Parameters to select:
%
%   num_words: number of visual words of the dictionary
%

% PARAMETERS

addpath('./yael_kmeans/');
NUM_WORDS = 4000;
DESC_PATH = './descriptors';
DICT_PATH = './dictionaries/%d';
FEAT_TYPE = 'SIFT';
CORRIDORS = 1:6;
PASSES    = 1:10;


% From the case of all passes contributing to the dictionary to the case of
% only one pass contributing to the dictionary, select all the possible
% combinations.

% For the time being, leave only one out.


dict_path = sprintf(DICT_PATH,NUM_WORDS);

for p = PASSES
    
    training_set = PASSES;
    training_set(p) = [];
    if strcmpi(FEAT_TYPE,'SIFT')
            cluster_descriptors_sparse(DESC_PATH,FEAT_TYPE,CORRIDORS,NUM_WORDS,training_set,dict_path)
    else % dense
            cluster_descriptors(DESC_PATH,FEAT_TYPE,CORRIDORS,NUM_WORDS,training_set,dict_path)
    end
end % end for loop
