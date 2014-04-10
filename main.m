% MAIN is a script that  selects the descriptors that are going to be
% computed on the visual paths datasets.
%
% Authors: Ioannis Alexiou and Jose Rivera-Rubio
%          {ia2109,jose.rivera}@imperial.ac.uk
% Date: November, 2013

% CONSTANT GLOBAL variables

DATASET_DIR = '/media/bg-PictureThis/VISUAL_PATHS/v5.0';

CORRIDORS = 2;

<<<<<<< HEAD
PASSES = 1:10;
=======
PASSES = 2;
>>>>>>> 0109b84412b19e8d289d8125864189fd1b16365c

FRAME_FOLDER = 'frames_resized_w208p';

DESCRIPTOR_DESTINATION_FOLDER = './descriptors';

DESCRIPTOR = 'ST_GAUSS'; % LWCOLOR, SIFT, DSIFT, SF_GABOR, ST_GABOR, ST_GAUSS,

PATHSEP = '/';

% Other global variables
descriptor_fname_str = 'C%dP%d';
% Main loop

for corr = CORRIDORS
    corridor = ['C' num2str(corr)];
    %h = waitbar(0,'Processing passes...');
    for p = PASSES
        pass = ['P' num2str(p)];
        working_path = fullfile(DATASET_DIR,corridor,'videos',num2str(p));
        frames_folder = fullfile(working_path,FRAME_FOLDER,filesep);
        
        writepath = fullfile(DESCRIPTOR_DESTINATION_FOLDER,...
                        DESCRIPTOR,['C' num2str(corr)],['P' num2str(p)],filesep);
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
                    ST_GABOR_Gradients(frames_folder,gradients_fname,writepath);
                   
                    % Construct the descriptor
                    ST_GABOR(gradients_fname,descriptor_fname,writepath);
                case 'ST_GAUSS' % Case of spatio-temporal Gaussians

                    gradients_fname = [descriptor_fname '_gradients'];
                    % Generate the gradients
                    ST_GAUSS_Gradients(frames_folder,gradients_fname,writepath);
                   
                    % Construct the descriptor
                    ST_GAUSS(gradients_fname,descriptor_fname,writepath);
            end
        %waitbar(j/PASSES(end));
    end
    %close(h);
end

