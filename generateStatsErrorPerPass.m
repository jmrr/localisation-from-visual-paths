function [Avg,st_dev] = generateStatsErrorPerPass(results_folder,corridors)
% Example usage: [Avg,st_dev] = generateStatsErrorPerPass('ResulsKernels/Lightweight',1:6)
D = dir(results_folder);

D = D(3:end);
fnames = cat(1,{D(:).name});

corridor_ids = cellfun(@(x) x(1:2),fnames,'UniformOutput',0);

for i = corridors

    corridor_prefix = ['C' num2str(i)];
    indices = find(strcmp(corridor_ids,corridor_prefix));
    
    for j = 1:length(indices)
    
        load([results_folder,'/',fnames{indices(j)}],'error_in_cm');
        Avg(i,j) = mean(error_in_cm);
        st_dev(i,j) = std(error_in_cm);
    end
    
end


end