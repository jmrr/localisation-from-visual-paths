% MAIN is a script that  selects the descriptors that are going to be
% computed on the visual paths dataset.
%
% Authors: Jose Rivera-Rubio and Ioannis Alexiou 
%          {jose.rivera,ia2109}@imperial.ac.uk
% Date: April, 2014

% CONSTANT GLOBAL variables

DATASET_DIR = '/media/bg-PictureThis/VISUAL_PATHS/v5.0';

CORRIDORS = 1:6;

PASSES = 1:10;

FRAME_FOLDER = 'frames_resized_w208p';

DESCRIPTOR_DESTINATION_FOLDER = './descriptors';

DESCRIPTOR = 'DSIFT'; % LW_COLOR, SIFT, DSIFT, SF_GABOR, ST_GABOR, ST_GAUSS,

% Other global variables
descriptor_fname_str = 'C%dP%d';

% MAIN LOOP

for corr = CORRIDORS
    corridor = ['C' num2str(corr)];
    %h = waitbar(0,'Processing passes...');
    for p = PASSES
        pass = ['P' num2str(p)];
        working_path = fullfile(DATASET_DIR,corridor,'videos',num2str(p));
        frames_folder = fullfile(working_path,FRAME_FOLDER,filesep);
        
        writepath = fullfile(DESCRIPTOR_DESTINATION_FOLDER,...
                        DESCRIPTOR,corridor,pass,filesep);
        % Create descriptor writepath if it doesn't exist
        mkdir(writepath);

        descriptor_fname = sprintf(descriptor_fname_str,corr,p);
        
            switch DESCRIPTOR
                
                case 'LW_COLOR' % Case of Lightweight color descriptors

                    LW_COLOR(frames_folder,descriptor_fname,writepath);
      
                case 'SF_GABOR' % Case of single-frame Gabor
                    
                    SF_GABOR(frames_folder,descriptor_fname,writepath);
                    
                case 'SIFT' % case of Sparse-SIFT based on keypoint detection
      
                    SIFT(frames_folder,descriptor_fname,writepath);
                    
                case 'DSIFT' % case of Dense-SIFT

                    DSIFT(frames_folder,descriptor_fname,writepath);
                    
                case 'ST_GABOR' % Case of spatio-temporal Gabors

                    gradients_fname = [descriptor_fname '_gradients'];
                    % Generate the gradients
                    [descProps] = ST_GABOR(frames_folder,gradients_fname,writepath);
                   
                    % Construct the descriptor
                    ST_descriptor_construction(gradients_fname,descriptor_fname,writepath,descProps);
                case 'ST_GAUSS' % Case of spatio-temporal Gaussians

                    gradients_fname = [descriptor_fname '_gradients'];
                    % Generate the gradients
                    [descProps] = ST_GAUSS(frames_folder,gradients_fname,writepath);
                   
                    % Construct the descriptor
                    ST_descriptor_construction(gradients_fname,descriptor_fname,writepath,descProps);
            end
            
        disp(['Finished encoding pass ' pass]);
    end
    fprintf('Finished computing descriptors %s for corridor %s.\n',DESCRIPTOR,corr);
    %close(h);
end

