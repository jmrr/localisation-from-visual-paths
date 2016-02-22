function SF_GABOR(seqPath, descrSavePath)
%   SF_GABOR  constructs a single-frame descriptor based on 17 DAISY-like
%   pooling arrangements applied over the result of 2D convolution
%   between the frames and and antysymmetric, 2D Gabors.
%
%   Inputs:
%       - seqPath: an existing path where the sequence images are stored
%       - descriptor_fname: a string representing the descriptor filename to be
%           used for the .mat descriptor data.
%       - writepath: an existing path where the .mat data with the
%           descriptors will be stored
%   
%    Authors: Jose Rivera and Ioannis Alexiou
%          April, 2014
%
% Count number of frames

files = dir([seqPath '*.jpg']); 

numFrames = length(files);

% Create pooling subspaces:

try
    hasCUDA = 1;
    LMs = gpuArray(poolingMappings);
catch
    hasCUDA = 0;
    disp('CUDA not available... trying CPU version')
    LMs = poolingMappings;
end
    
% num_pixels = numel(I);

% Preallocate memory for data structures: grid and descriptor stacks.

GridStack = [];
DescriptorStack = [];

% Run for all the frames in the video sequence

for n = 1:numFrames

    I = rgb2gray(imread([seqPath files(n).name]));

    G = zeros(size(I,1),size(I,2),4,'double');
    orientationSpace = zeros(size(I,1),size(I,2),8,'double');
    
    % Convolve the image with the Gabor (g), to yield G
    
    for or = 1:4 
        G(:,:,or) = conv2(double(I),double(imag(gabor(2,45*(or-1),4,0,1))),'same'); 
    end
    
    % To obtain the orientation space (8 discrete orientations)
    
    for L = 1:4
        orientationSpace(:,:,L) = max(G(:,:,L),0); 
        orientationSpace(:,:,L+4) = -min(G(:,:,L),0); 
    end
    
    % Create the sampling grids
    step = 3;
    emptyImg = zeros(size(I,1),size(I,2));
    [Grid,Y,X,LinSize] = MakeGrids(emptyImg,step);

    if(hasCUDA)
        DenseMag = PoolingLayer(emptyImg,gpuArray(orientationSpace),LobeMaps,LinSize,Y,X, hasCUDA);
    else
        DenseMag = PoolingLayer(emptyImg,orientationSpace,LobeMaps,LinSize,Y,X, hasCUDA);
    end

    DenseMag = DenseMag ./ repmat(sqrt(sum(DenseMag.^2,2))+eps,[1,size(DenseMag,2)]);

    DescriptorStack = cat(3,DescriptorStack,DenseMag);
    GridStack = cat(3,GridStack,Grid);

end

save(descrSavePath,'DescriptorStack','GridStack','-v7.3')
end % end SF_GABOR

function [GridLin,Y,X,LinSize] = MakeGrids(I,step)

    Grid = RegularGrid(zeros(size(I)),step,6); % step=3

    Y = Grid{1}(:,1);
    X = Grid{2}(1,:);

    GridLin = [Grid{1}(:),Grid{2}(:)];

    LinSize = size(Grid{1},1)*size(Grid{1},2);
    
end % end MakeGrids

function DM = PoolingLayer(I,orientationSpace,LobeMap,LinSize,Y,X, hasCUDA)

    NumAttr = 17;
    NumGrads = 8;
    
    if(hasCUDA)
        DenseMag = gpuArray.zeros(size(I,1),size(I,2),NumAttr*NumGrads,'double');
    else
        DenseMag = zeros(size(I,1),size(I,2),NumAttr*NumGrads);
    end

    for attr = 1:NumAttr

        % Obtain the dense descriptors (1 descriptor per pixel) as the
        % outputs of a dot product at the sampling locations (equivalent
        % to 2D convolution over the whole image in one operation.

        DenseMag(:,:,(attr-1)*NumGrads+(1:NumGrads)) = ... 
        imfilter(orientationSpace,LobeMap(:,:,attr),'symmetric','conv') ;

    end

    % Sub-sample according to the dense grid.
    % Reshape to fit the structure Npoints_grid x Dimension_descriptor
    DM = gather(DenseMag);
    DM = reshape(DM(Y,X,:),LinSize,NumAttr*NumGrads);
    
end % end Pooling Layer


function [Grid,BorderOffsets] = RegularGrid(Input,step,BorderOffsets)

    [y,x] = size(Input);
    dy = 1:step:y;
    dx = 1:step:x;
    % BorderOffsets=17;%round(10*2.^(1:0.25:3.25));
    Grid = cell(2,length(BorderOffsets));
    
    for bo = 1:length(BorderOffsets)

        indy = dy > BorderOffsets(bo) & dy < (y-BorderOffsets(bo));
        indx = dx > BorderOffsets(bo) & dx < (x-BorderOffsets(bo));
        Grid(1,bo) = {repmat(dy(indy)',1,length(dx(indx)))};
        Grid(2,bo) = {repmat(dx(indx),length(dy(indy)),1)};
    end

end % end RegularGrid
 