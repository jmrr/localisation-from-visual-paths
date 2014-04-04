function DSIFT(path,fname,writepath)
% 
% tname=dir([path '*.mp4']);
% 
% filename = [path tname.name];
% obj = VideoReader(filename);

files = dir([path '*.jpg']);

% num Frames
numFrames = length(files); %get(obj, 'NumberOfFrames');

single_frame = imread([path files(1).name]);

Height = size(single_frame, 1);
Width = size(single_frame, 2);

MemSize = Height * Width * numFrames * 4/1e9; % memory in GB

disp([num2str(MemSize) 'GB RAM Memory Occupancy'])

% Preallocate memory for data structures: grid and descriptor stacks.

GridStack = [];
DescriptorStack = [];

% SIFT descriptor parameters

smoothingSigma = 1.2; % smoothingSigma = (binSize/magnif)^2 - .25; where 
                      % magnif is the relationship between keypoint scale
                      % and bin size. By default, magnif is 3.00
                      
step = 3; % Step between descriptor centres, or grid step size.

binSize = 3; 

for i = 1:numFrames

    I = single(rgb2gray(imread([path files(i).name])));
    
    Is = vl_imsmooth(I,smoothingSigma);
    
    [Grid,Descriptors] = vl_dsift(Is,'step',step,'size',binSize,'FloatDescriptors');

    Descriptors = Descriptors';

    normalisedDescriptors = Descriptors ./ repmat(sqrt(sum(Descriptors.^2,2))+eps...
        ,[1,size(Descriptors,2)]);

    GridStack = cat(3,GridStack,single(Grid'));
    DescriptorStack = cat(3,DescriptorStack,single(normalisedDescriptors));

end

save([writepath  fname '_Descriptors'],'DescriptorStack','GridStack','-v7.3')

end % end DSIFT function
