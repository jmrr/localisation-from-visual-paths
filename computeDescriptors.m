function [] = computeDescriptors(params)
% COMPUTEDESCRIPTORS is a function that  selects the descriptors that are going to be
% computed on the visual paths dataset.

% Authors: Jose Rivera-Rubio and Ioannis Alexiou
%          {jose.rivera,ia2109}@imperial.ac.uk
% Date: November, 2014

% Other global variables
descrFnameStr = 'C%dP%d';

% MAIN LOOP

for corr = params.corridors
    corridor = ['C' num2str(corr)];
    %h = waitbar(0,'Processing passes...');
    for p = params.passes
        pass = ['P' num2str(p)];
        workingPath = fullfile(params.datasetDir,corridor,'videos',num2str(p));
        framesDir = fullfile(workingPath,params.frameDir,filesep);
        
        writepath = fullfile(params.descrDir,...
            params.descriptor,corridor,pass,filesep);
        % Create descriptor writepath if it doesn't exist
        mkdir(writepath);
        
        descrFname    = sprintf(descrFnameStr,corr,p);
        descrSavePath = [writepath  descrFname '_Descriptors'];
        
        if (~exist([descrSavePath '.mat'], 'file'))
            
            switch params.descriptor
                
                case 'LW_COLOR' % Case of Lightweight color descriptors
                    
                    LW_COLOR(framesDir, descrSavePath);
                    
                case 'SF_GABOR' % Case of single-frame Gabor
                    
                    SF_GABOR(framesDir, descrSavePath);
                    
                case 'SIFT' % case of Sparse-SIFT based on keypoint detection
                    
                    SIFT(framesDir, descrSavePath);
                    
                case 'DSIFT' % case of Dense-SIFT
                    
                    DSIFT(framesDir, descrSavePath);
                    
                case 'ST_GABOR' % Case of spatio-temporal Gabors
                    
                    gradientsFname = [descrFname '_gradients'];
                    % Generate the gradients
                    [descProps] = ST_GABOR(framesDir,gradientsFname,writepath);
                    
                    % Construct the descriptor
                    ST_descriptor_construction(gradientsFname, descrSavePath, descProps);
                case 'ST_GAUSS' % Case of spatio-temporal Gaussians
                    
                    gradientsFname = [descrFname '_gradients'];
                    % Generate the gradients
                    [descProps] = ST_GAUSS(framesDir,gradientsFname,writepath);
                    
                    % Construct the descriptor
                    ST_descriptor_construction(gradientsFname, descrSavePath, descProps);
            end
            
            disp(['Finished encoding pass ' pass]);
        end
        disp('Descriptor already exist');
    end
    fprintf('Finished computing descriptors %s for corridor %s.\n', params.descriptor, num2str(corr));
    %close(h);
end

end