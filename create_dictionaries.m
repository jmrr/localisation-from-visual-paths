% CREATE_DICTIONARIES generates all the combination of passes and calls
% cluster_descriptors to construct bag of visual words (BOVW) dictionaries.
%
% Parameters to select:
%
%   num_words: number of visual words of the dictionary
%

addpath('./yael_kmeans/');
num_words = 4000;

descriptors_path = './descriptors';
feature_type = 'ST_GAUSS';
corridors = 1:6;
dict_path = 'dictionaries';

% From the case of all passes contributing to the dictionary to the case of
% only one pass contributing to the dictionary, select all the possible
% combinations.

% For the time being, leave only one out.

passes = 1:10;

for p = passes
    
    training_set = passes;
    training_set(p) = [];
    
    cluster_descriptors(descriptors_path,feature_type,corridors,num_words,training_set,dict_path)
    
end % end for loop
