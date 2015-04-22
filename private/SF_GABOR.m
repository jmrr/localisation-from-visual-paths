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

LMs = gpuArray(PoolingMappings);

% num_pixels = numel(I);

% Preallocate memory for data structures: grid and descriptor stacks.

GridStack = [];
DescriptorStack = [];

% Run for all the frames in the video sequence

for n = 1:numFrames

    I = single(rgb2gray(imread([seqPath files(n).name])));

    Raw = zeros(size(I,1),size(I,2),4,'single');
    scale_space = zeros(size(I,1),size(I,2),8,'single');
    
    % Convolve the image with the Gabor
    
    for or = 1:4 
        Raw(:,:,or) = conv2(I,imag(gabor(2,45*(or-1),4,0,1)),'same'); 
    end
    
    % To obtain the scale space
    
    for L = 1:4
        scale_space(:,:,L) = max(Raw(:,:,L),0); 
        scale_space(:,:,L+4) = -min(Raw(:,:,L),0); 
    end
    
    % Create the sampling grids
    step = 3;
    emptyImg = zeros(size(I,1),size(I,2));
    [Grid,Y,X,LinSize] = MakeGrids(emptyImg,step);

    
    DenseMag = PoolingLayer(emptyImg,gpuArray(scale_space),LMs,LinSize,Y,X);

    DenseMag = single( DenseMag ./ repmat(sqrt(sum(DenseMag.^2,2))+eps,[1,size(DenseMag,2)]) );

    DescriptorStack = cat(3,DescriptorStack,single(DenseMag));
    GridStack = cat(3,GridStack,single(Grid));

end

save([writepath  descrSavePath '_Descriptors'],'DescriptorStack','GridStack','-v7.3')
end % end SF_GABOR

function [GridLin,Y,X,LinSize] = MakeGrids(I,step)

    Grid = RegularGrid(zeros(size(I)),step,6); % step=3

    Y = Grid{1}(:,1);
    X = Grid{2}(1,:);

    GridLin = [Grid{1}(:),Grid{2}(:)];

    LinSize = size(Grid{1},1)*size(Grid{1},2);
    
end % end MakeGrids

function DM = PoolingLayer(I,scale_space,LMap,LinSize,Y,X)

    NumAttr = 17;
    NumGrads = 8;

    DenseMag = gpuArray.zeros(size(I,1),size(I,2),NumAttr*NumGrads,'single');

    for attr = 1:NumAttr

        % Obtain the dense descriptors (1 descriptor per pixel) as the
        % outputs of a dot product at the sampling locations (equivalent
        % to 2D convolution over the whole image in one operation.

        DenseMag(:,:,(attr-1)*NumGrads+(1:NumGrads)) = ... 
        imfilter(scale_space,LMap(:,:,attr),'symmetric','conv') ;

    end

    % Sub-sample according to the dense grid.
    DM = gather(DenseMag);

    % Reshape to fit the structure Npoints_grid x Dimension_descriptor
    DM = reshape(DM(Y,X,:),LinSize,NumAttr*NumGrads);
    
end % end Pooling Layer

function LMs = PoolingMappings

    diameter = 11;
    % M=SiftMaps(Diameter);
    % PS = Diameter*Diameter;

    % Parameters
    alpha_center = 20; %1/alpha_center = 0.05, 0.02 0.03 *mlt
    % rho=[0 0.3 0.4]; VOC % 0.35 0.85 initially 0 0.3 0.7 r1 r2
    rho = [0 0.45 0.6]; % Caltech
    alpha = 4;  %1/alpha = 5.8 2.8 0.3 %0.25 *mlt
    beta = 0.4;  %1/beta = 2.5 1.1 1.2 0.18*mlt

    extended_diameter = diameter*20;    % 20 times the diameter is enough area to
                                       % build the subspaces

    Map = attentional_subspaces(extended_diameter,rho,alpha_center,alpha,beta);

    M = imresize(Map(:,:,8:end),[diameter diameter],'bilinear');

    % Normalisation

    LinMaps = single(M);

    LinMaps = LinMaps ./ repmat(sum(sum(LinMaps)),[diameter,diameter,1]);

    LMs = LinMaps;
    
end % end PoolingMappings

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
 