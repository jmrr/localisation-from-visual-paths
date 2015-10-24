function encoding(params)

trainingSet = params.trainingSet;

if ~exist('trainingSet','var') || isempty(trainingSet)
    hovwEncoding(params); % if no training set, leave one out
else
    hovwEncodingCustom(params,params.trainingSet, params.passes);
end

end % end function encoding