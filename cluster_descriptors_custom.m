function cluster_descriptors_custom(training_set, params)

dict_path = fullfile(params.dictPath,num2str(params.dictionarySize));
cluster_descriptors(params.descrDir,params.descriptor,params.corridors,params.dictionarySize,training_set,dict_path)
end