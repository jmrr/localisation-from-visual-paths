function [] = computeDescriptors(params)
% COMPUTEDESCRIPTORS is a function that  selects the descriptors that are going to be
% computed on the visual paths dataset.
%
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

        descrFname = sprintf(descrFnameStr,corr,p);
        
            switch params.descriptor
                
                case 'LW_COLOR' % Case of Lightweight color descriptors

                    LW_COLOR(framesDir,descrFname,writepath);
      
                case 'SF_GABOR' % Case of single-frame Gabor
                    
                    SF_GABOR(framesDir,descrFname,writepath);
                    
                case 'SIFT' % case of Sparse-SIFT based on keypoint detection
      
                    SIFT(framesDir,descrFname,writepath);
                    
                case 'DSIFT' % case of Dense-SIFT

                    DSIFT(framesDir,descrFname,writepath);
                    
                case 'ST_GABOR' % Case of spatio-temporal Gabors

                    gradientsFname = [descrFname '_gradients'];
                    % Generate the gradients
                    [descProps] = ST_GABOR(framesDir,gradientsFname,writepath);
                   
                    % Construct the descriptor
                    ST_descriptor_construction(gradientsFname,descrFname,writepath,descProps);
                case 'ST_GAUSS' % Case of spatio-temporal Gaussians

                    gradientsFname = [descrFname '_gradients'];
                    % Generate the gradients
                    [descProps] = ST_GAUSS(framesDir,gradientsFname,writepath);
                   
                    % Construct the descriptor
                    ST_descriptor_construction(gradientsFname,descrFname,writepath,descProps);
            end
            
        disp(['Finished encoding pass ' pass]);
    end
    fprintf('Finished computing descriptors %s for corridor %s.\n',params.descriptor,num2str(corr));
    %close(h);
end

end