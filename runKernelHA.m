function [] = runKernelHA(params)
% RUNKERNELHA constructs the Hard Assignment kernel based on the chi2
% distance

% Authors: Jose Rivera-Rubio and Ioannis Alexiou
%          {jose.rivera,ia2109}@imperial.ac.uk
% Initial version: April, 2014
% Last Modified: Otober, 2015

% Parse input

trainingSet = params.trainingSet;

for corr = params.corridors
    
    for pass = params.passes
        
        c = ['C' num2str(corr)]; % corridor string
        p = ['P' num2str(pass)]; % pass string
        
        if ~exist('trainingSet','var') || isempty(trainingSet)
            
            trainingSet = params.passes;
            
            if (length(trainingSet) <= 1)
                trainingSet = params.passes;
            else
                trainingSet(pass) = [];
            end
            
        end
        computeKernel(params, trainingSet, c,corr,pass)
        disp(['Finished encoding pass ' p]);
    end
    
    fprintf('Hard assignment encoding done for corridor %s.\n',c);
    warning('on');
    
end


end %end runKernelHA function



function computeKernel(params, trainingSet, c,corr,pass)

% Path strings, modify if NOT using the default suggested paths.
hovwStr    = 'hovw_%s_C%d_P%s_%d.mat';
kernelStr  = 'C%d_kernel_%s_%s_P%s_%d.mat';
dictPath   = fullfile(params.dictPath,num2str(params.dictionarySize));
kernelPath = fullfile(params.kernelPath,params.encoding);

% Construct dictionary path and load encoded pass.
dictionariesPath = fullfile(dictPath,params.descriptor,c);

trainingSetStr = sprintf('%d',trainingSet);
hovwFnameStr = sprintf(hovwStr,params.encoding,corr,trainingSetStr,pass);

load(fullfile(dictionariesPath,hovwFnameStr)); % Load VWords

% Normalize the HOVWENCODING

stackQ = HoVW./repmat(sqrt(sum(HoVW.^2,2))+eps,[1,size(HoVW,2)]);

stackQ = vl_homkermap(stackQ',1,'kchi2');

% Generate the kernel of distances to the other passes
idx =  1;

for db = trainingSet
    
    % Construct dictionary path and load encoded pass.
    
    dictionariesPath = fullfile(dictPath,params.descriptor,c);
    hovwFnameStr = sprintf(hovwStr,params.encoding,corr,trainingSetStr,db);
    
    currDbFile = dir(fullfile(dictionariesPath,hovwFnameStr));
    
    load(fullfile(dictionariesPath,currDbFile(1).name)); % Load encoded db pass
    
    % Normalise and stack
    
    stackDb = HoVW./repmat(sqrt(sum(HoVW.^2,2))+eps,[1,size(HoVW,2)]);
    
    stackDb = vl_homkermap(stackDb',1,'kchi2');
    
    % Construct Chi2 kernel
    
    Kernel(idx) = {stackQ'*stackDb};
    
    idx = idx+1;
    
end

% Save kernel

save_path = fullfile(kernelPath,params.descriptor,c);

mkdir(save_path);
warning('off');

kernel_fname_str = sprintf(kernelStr,corr,params.encoding,params.kernel,trainingSetStr,pass);

save(fullfile(save_path,kernel_fname_str),'Kernel');

clear Kernel;


end % end computeKernel