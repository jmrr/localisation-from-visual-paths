function [] = createDictionaries(params, varargin)
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
% See also private/CLUSTERDESCRIPTORS, private/CLUSTERDESCRIPTORSSPARSE

% Authors: Jose Rivera-Rubio
%          {jose.rivera}@imperial.ac.uk
%
% Initial version: April, 2014
% Last Modified: Otober, 2015

% Parse input, check if trainingSet is specified, otherwise leave one out
% will be used

if nargin > 1
    trainingSet = varargin{1};
end

dictPath = fullfile(params.dictPath,num2str(params.dictionarySize));

if ~exist('trainingSet','var') || isempty(trainingSet)
    % Leave one out, so it will create one dictionary per leave one out
    % combination.
    for p = params.passes
        trainingSet = params.passes;
        if (length(trainingSetZ) <= 1)
            trainingSet = params.passes;
        else
            trainingSet(p) = [];
        end
        
        cluster()
        
    end % end for loop for passes
    
else % Only one trainging set -> only one dictionary
    
    cluster()
   
end

    function cluster
        
        if strcmpi(params.descriptor,'SIFT')
            clusterDescriptorsSparse(params.descrDir,params.descriptor,params.corridors,params.dictionarySize,trainingSet,dictPath)
        else % dense
            clusterDescriptors(params.descrDir,params.descriptor,params.corridors,params.dictionarySize,trainingSet,dictPath)
        end
    end
end % end createDictionaries
