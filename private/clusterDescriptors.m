function [] = clusterDescriptors(descriptorsPath,feature,corridors,numWords,trainingSet,dictPath)
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

    for passes = trainingSet
        
        c = ['C' num2str(corr)]; % corridor string
        p = ['P' num2str(passes)]; % pass string
        
        % Load all the descriptors for this particular pass.
        load(fullfile(descriptorsPath,feature,c,p,...
            [c p '_Descriptors.mat']));
        descDim = size(DescriptorStack,2);
        % Randomly select 800 descriptors from each frame
        randomDescriptorSet = randi([1 size(DescriptorStack,3)],[1 800]);
        
        % Randomly select 200 frames from the whole sequence
        randomFramesSet = randi([1 size(DescriptorStack,1)],[1 200]);
        
        % Stack up the selected descriptors (row wise).
        selectedDescriptors = [selectedDescriptors; ...
            reshape(shiftdim(DescriptorStack(randomFramesSet,:,randomDescriptorSet),2),...
            [],descDim)];
        
        % Free up some memory
        clear DescriptorStack GridStack;
    end % end for passes
    
    % Normalisation of the selected descriptors
    
    normalizedDescriptors = sqrt(sum(selectedDescriptors.^2,2));
    
    selectedDescriptors = ...
        selectedDescriptors./repmat((normalizedDescriptors + eps),[1,descDim]);
    
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
