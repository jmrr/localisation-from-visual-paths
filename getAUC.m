function [Auc] = getAUC(path2results)

load(path2results);
clear path2results;
methods = who;
num_methods = length(methods);

Auc = struct('method',{},'mean_AUC',{},'max_AUC',{},'min_AUC',{});

for i = 1:num_methods
    
    pdf = eval(methods{i});
    cdf = cumsum(pdf,2);
    auc = trapz(cdf,2);
    Auc(i).method = methods{i};
    Auc(i).mean_AUC = mean(auc);
    Auc(i).max_AUC = max(auc);
    Auc(i).min_AUC = min(auc);
end
    
end % end function