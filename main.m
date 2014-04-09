% MAIN is a script that  selects the descriptors that are going to be
% computed on the visual paths datasets.
%
% Authors: Ioannis Alexiou and Jose Rivera-Rubio
%          {ia2109,jose.rivera}@imperial.ac.uk
% Date: November, 2013

% CONSTANT GLOBAL variables

DATASET_DIR = '/media/bg-PictureThis/VISUAL_PATHS/v5.0';

CORRIDORS = 1:6;

PASSES = 1:5;

FRAME_FOLDER = 'frames_resized_w208p';

DESCRIPTOR_DESTINATION_FOLDER = './descriptors';

DESCRIPTOR = 'ST_GABOR';

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
        
            switch DESCRIPTOR
                
                case 'LW_COLOR' % Case of Lightweight color descriptors
                    DescriptorBlocks = generateSignals(frames_folder);
                    save([DESCRIPTOR_DESTINATION_FOLDER '/DB' corridor pass '.mat'],'DescriptorBlocks');
        
                case 'SF_GABOR' % Case of single-frame Gabor

                    writepath = fullfile(DESCRIPTOR_DESTINATION_FOLDER,...
                        ['C' num2str(corr)],DESCRIPTOR,filesep);
   
                    descriptor_fname = sprintf(descriptor_fname_str,corr,p);
                    
                    SF_GABOR(frames_folder,descriptor_fname,writepath);
                case 'SIFT' % case of Dense-SIFT
                    writepath = fullfile(DESCRIPTOR_DESTINATION_FOLDER,...
                        ['C' num2str(corr)],DESCRIPTOR,filesep);
                    % Create descriptor writepath if it doesn't exist
                    mkdir(writepath);
                    descriptor_fname = sprintf(descriptor_fname_str,corr,p);

                    DSIFT(frames_folder,descriptor_fname,writepath);
                case 'ST_GABOR' % Case of spatio-temporal Gabors
                    writepath = fullfile(DESCRIPTOR_DESTINATION_FOLDER,...
                        ['C' num2str(corr)],DESCRIPTOR,filesep);
                    % Create descriptor writepath if it doesn't exist
                    mkdir(writepath);
                    descriptor_fname = sprintf(descriptor_fname_str,corr,p);
                    
                    % Generate the gradients
                    ST_GABOR_Gradients(frames_folder,descriptor_fname,writepath);
                   
                    % Construct the descriptor
                    ST_GABOR(descriptor_fname,writepath)
            end
        %waitbar(j/PASSES(end));
    end
    %close(h);
end

