function batchEncoding(params)

corridors   = params.corridors;
trainingSet = params.trainingSet;

for c = corridors
    
    params.corridors = c;
    
    if(~exist('trainingSet','var'))
        hovwEncoding(params); % if no training set, leave one out
    else
        hovwEncodingCustom(params,params.trainingSet, params.passes);
    end
    
end % end function encoding

end