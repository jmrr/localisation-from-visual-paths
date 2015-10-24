function [] = clusterDescriptorsSparse(descriptorsPath,feature,corridors,numWords,trainingSet,dictPath)
% CLUSTER_DESCRIPTORS(descriptors_path,feature_type,num_words,training_set)
% groups randomly selected descriptors from the specified training set into 
% num_words clusters using k-means.
%
% Requirements: YAEL K-MEANS package for fast clustering.
% https://gforge.inria.fr/projects/yael/
%

% Authors: Jose Rivera and Ioannis Alexiou
%          October, 2015

selectedDescriptors = [];

for corr = corridors

    for pass = trainingSet
        
        c = ['C' num2str(corr)]; % corridor string
        p = ['P' num2str(pass)]; % pass string
        
        % Load all the descriptors for this particular pass.
        load(fullfile(descriptorsPath,feature,c,p,...
            [c p '_Descriptors.mat']));
        descDim = size(DescriptorStack{1},1); % Size of descriptors
        numDesc = size(DescriptorStack{1},2); % Number of descriptors
        
        % Stack up the selected descriptors (row wise).
        selectedDescriptors = [selectedDescriptors; cat(2,DescriptorStack{:})']; % transpose for coherence with dense code.
        
        % Free up some memory
        clear DescriptorStack GridStack;
    end % end for passes
    
    % Normalisation of the selected descriptors
    
    normalizedDescriptors = sqrt(sum(selectedDescriptors.^2,2));
    
    selectedDescriptors = ...
        double(selectedDescriptors)./repmat((normalizedDescriptors + eps),[1,descDim]);
    
    % Show message
    trainingName = sprintf('%d',trainingSet);

    fprintf('Permuted samples from: %s\n',trainingName);
    
    % K-MEANS (Requires Yael k-means from INRIA).
    
    VWords = yael_kmeans(single(selectedDescriptors)',numWords,'niter',20,'verbose',2,'seed',3);
    
    % Save dictionary
    savepath = fullfile(dictPath,feature,c);
    mkdir(savepath);
    save(fullfile(savepath,['dictionary_' c '_P' trainingName '.mat']),'VWords')

    
end % end for corridors

disp(['Corridor ' c ' completed']);
