function SIFT(path, descrSavePath)

files = dir([path '*.jpg']);

% num Frames
numFrames = length(files); 

% Allocate space for the descriptor stack

DescriptorStack = [];

for i = 1:numFrames
    
    I = single(rgb2gray(imread([path files(i).name])));
    
    [keypoints, descriptors] = vl_sift(I,'PeakThresh',0);
    
    DescriptorStack{i} = descriptors; % Nx128 
    KeypointStack{i} = keypoints;
end

save(descrSavePath,'DescriptorStack','KeypointStack','-v7.3')
