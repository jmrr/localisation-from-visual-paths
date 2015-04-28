function encoding(params)

if(isempty(params.trainingSet)) 
    hovwEncoding(params); % if no training set, leave one out
else
    hovwEncodingCustom(params,params.trainingSet, params.passes);
end

end % end function encoding