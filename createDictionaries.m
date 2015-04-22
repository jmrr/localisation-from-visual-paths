function [] = createDictionaries(params, trainingSet)
% CREATEDICTIONARIES generates all the combination of passes and calls
% cluster_descriptors to construct bag of visual words (BOVW) dictionaries.
%
% Parameters to be used:
%
%   dictionarySize: number of visual words of the dictionary
%
% From the case of all passes contributing to the dictionary to the case of
% only one pass contributing to the dictionary, select all the possible
% combinations.
% For the time being, leave only one out.
%
% See also private/CLUSTER_DESCRIPTORS, private/CLUSTER_DESCRIPTORS_SPARSE

% Authors: Jose Rivera-Rubio
%          {jose.rivera}@imperial.ac.uk
% Date: November, 2014


dictPath = fullfile(params.dictPath,num2str(params.dictionarySize));

for p = params.passes
    
    training_set = params.passes;
    if (length(training_set) <= 1)
        training_set = params.passes;
    else
        training_set(p) = [];
        
    end
    if strcmpi(params.descriptor,'SIFT')
        clusterDescriptorsSparse(params.descrDir,params.descriptor,params.corridors,params.dictionarySize,trainingSet,dictPath)
    else % dense
        clusterDescriptors(params.descrDir,params.descriptor,params.corridors,params.dictionarySize,trainingSet,dictPath)
    end
end % end for loop

end % end createDictionaries
