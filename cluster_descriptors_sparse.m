function [] = cluster_descriptors_sparse(descriptors_path,feature_type,corridors,num_words,training_set,dict_path)
% CLUSTER_DESCRIPTORS(descriptors_path,feature_type,num_words,training_set)
% groups randomly selected descriptors from the specified training set into 
% num_words clusters using k-means.
%
% Requirements: YAEL K-MEANS package for fast clustering.
% https://gforge.inria.fr/projects/yael/
%
%   
% Authors: Jose Rivera and Ioannis Alexiou
%          April, 2014

selected_descr = [];

for corr = corridors

    for pass = training_set
        
        c = ['C' num2str(corr)]; % corridor string
        p = ['P' num2str(pass)]; % pass string
        
        % Load all the descriptors for this particular pass.
        load(fullfile(descriptors_path,feature_type,c,p,...
            [c p '_Descriptors.mat']));
        desc_dim = size(DescriptorStack{1},1); % Size of descriptors
        num_desc = size(DescriptorStack{1},2); % Number of descriptors
        
        % Stack up the selected descriptors (row wise).
        selected_descr = [selected_descr; cat(2,DescriptorStack{:})']; % transpose for coherence with dense code.
        
        % Free up some memory
        clear DescriptorStack GridStack;
    end % end for passes
    
    % Normalisation of the selected descriptors
    
    desc_norm = sqrt(sum(selected_descr.^2,2));
    
    selected_descr = ...
        double(selected_descr)./repmat((desc_norm + eps),[1,desc_dim]);
    
    % Show message
    training_name = sprintf('%d',training_set);

    fprintf('Permuted samples from: %s\n',training_name);
    
    % K-MEANS (Requires Yael k-means from INRIA).
    
    VWords = yael_kmeans(single(selected_descr)',num_words,'niter',20,'verbose',2,'seed',3);
    
    % Save dictionary
    savepath = fullfile(dict_path,feature_type,c);
    mkdir(savepath);
    save(fullfile(savepath,['dictionary_' c '_P' training_name '.mat']),'VWords')

    
end % end for corridors

disp(['Corridor ' c ' completed']);
