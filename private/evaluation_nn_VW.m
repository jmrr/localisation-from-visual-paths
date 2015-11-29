function [] = evaluation_nn_VW(params, kernel_results_path)
%EVALUATION_NN_VW obtains the closest neighbour distance for every frame in a
%query pass based on visual words.
% -Inputs:
%   params = main parameter data structure
%   results_path = absolute path storing the '.mat' files containing
%   kernels.
%   ground_truth_path = absolute path of the ground truth csv files.
%   metric = 'min' or 'max' depending on if the similarity measure is
%   distance based ('min' distance == closest match) or score based ('max'
%   score == closest match).
%
%
% - NOTE: The results are saved in a separate 4xnum_queries array
%
% -Example usage:
%   evaluation_nn('/full/path/to/results','/full/path/to/ground_truth','min')
%

% Authors: Jose Rivera-Rubio and Ioannis Alexiou
%          {jose.rivera,ia2109}@imperial.ac.uk
% Date: November, 2014

% Constants and paths

gt_file_str = 'ground_truth_C%d_P%d.csv';

% Load the results file

D = dir(kernel_results_path);

D = D(3:end);

num_results_files = length(D);

if (params.debug)
    waitbar_msg = '%d/%d files processed';
    h = waitbar(0,sprintf(waitbar_msg,0,num_results_files));
end

for idx_files = 1:num_results_files
    
    % Result file path and filename for parsing
    
    results_file = fullfile(kernel_results_path,D(idx_files).name);
    load(results_file);
    
    %% Cleaning from previous version:
    results = [];
    error_in_cm = [];
    
    [~,fname] = fileparts(D(idx_files).name);
    fname_str = textscan(fname,'%s','Delimiter','_');
    fname_str = fname_str{1};
    
    % Get ground truth for all the passes
    corridor = str2double(fname_str{1}(end)); % Corridor is in the last
    % character of the first
    % string
    
    for pass = params.passes
        
        gt_file = sprintf(gt_file_str,corridor,pass);
        if params.passes(1) == 0
            gt{pass+1} = csvread(fullfile(params.groundTruthPath,gt_file),1,1);
        else
            gt{pass} = csvread(fullfile(params.groundTruthPath,gt_file),1,1);
        end
        
    end
    
    % Which is the query pass? The last character denotes it
    
    query_pass = str2double(fname_str(end));
    
    % Ground truth for the query...
    
    gt_query = gt{query_pass};
    
    % Once this is known, modify the training indices
    training_set = params.passes;
    
    if (length(training_set) <= 1)
        training_set = params.passes;
    else
        training_set(query_pass) = [];
    end
    
    if(strcmp(params.metric,'min'))
        
        [v,idx] = cellfun(@(x) min(x,[],2),Kernel,'uniformoutput',false);
        values = cat(2,v{:});
        indices = cat(2,idx{:});
        
        [~,whichPass] = min(values,[],2);
        
        
    elseif(strcmp(params.metric,'max'))
        
        [v,idx] = cellfun(@(x) max(x,[],2),Kernel,'uniformoutput',false);
        values = cat(2,v{:});
        indices = cat(2,idx{:});
        
        [~,whichPass] = max(values,[],2);
        
    else
        error('Metric choice not recognized. Choose between ''min'' or ''max''.');
    end
    
    % Compute the estimated position
    
    Estimated_Location = zeros(size(Kernel{1},1),1);
    
    Estimated_Location = ...
        SelectLocationEsts(Estimated_Location,gt,whichPass,indices,training_set);
    
    % Compute the error
    error_in_cm = abs(gt_query(1:length(Estimated_Location)) - Estimated_Location);
    % Save (together with the kernels).
    
    save(results_file,'results','Estimated_Location','gt_query','error_in_cm','-append');
    
    if(params.debug)
        waitbar(idx_files/num_results_files,h,sprintf(waitbar_msg,idx_files,num_results_files));
    end
end

if(params.debug)
    close(h);
end

end


function Estimated_Location = SelectLocationEsts(Estimated_Location,GT,whichPass,indices,trainset)

for i = 1:length(trainset)
    
    MatchGT{i} = GT{trainset(i)};
    
end

for i= 1:length(Estimated_Location)
    
    Estimated_Location(i) = MatchGT{whichPass(i)}(indices(i,whichPass(i)));
    
end

end