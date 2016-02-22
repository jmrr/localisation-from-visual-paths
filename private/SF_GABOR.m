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
    LMs = gpuArray(PoolingMappings);
catch
    hasCUDA = 0;
    disp('CUDA not available... trying CPU version')
    LMs = PoolingMappings;
end
    
% num_pixels = numel(I);

% Preallocate memory for data structures: grid and descriptor stacks.

GridStack = [];
DescriptorStack = [];

% Run for all the frames in the video sequence

for n = 1:numFrames

    I = rgb2gray(imread([seqPath files(n).name]));

    G = zeros(size(I,1),size(I,2),4,'double');
    ScaleSpace = zeros(size(I,1),size(I,2),8,'double');
    
    % Convolve the image with the Gabor (g), to yield G
    
    for or = 1:4 
        G(:,:,or) = conv2(double(I),double(imag(gabor(2,45*(or-1),4,0,1))),'same'); 
    end
    
    % To obtain the scale space
    
    for L = 1:4
        ScaleSpace(:,:,L) = max(G(:,:,L),0); 
        ScaleSpace(:,:,L+4) = -min(G(:,:,L),0); 
    end
    
    % Create the sampling grids
    step = 3;
    emptyImg = zeros(size(I,1),size(I,2));
    [Grid,Y,X,LinSize] = MakeGrids(emptyImg,step);

    if(hasCUDA)
        DenseMag = PoolingLayer(emptyImg,gpuArray(ScaleSpace),LobeMaps,LinSize,Y,X, hasCUDA);
    else
        DenseMag = PoolingLayer(emptyImg,ScaleSpace,LobeMaps,LinSize,Y,X, hasCUDA);
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

function DM = PoolingLayer(I,ScaleSpace,LobeMap,LinSize,Y,X, hasCUDA)

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
        imfilter(ScaleSpace,LobeMap(:,:,attr),'symmetric','conv') ;

    end

    % Sub-sample according to the dense grid.
    % Reshape to fit the structure Npoints_grid x Dimension_descriptor
    DM = gather(DenseMag);
    DM = reshape(DM(Y,X,:),LinSize,NumAttr*NumGrads);
    
end % end Pooling Layer

function LobeMaps = PoolingMappings

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

    LinMaps = double(M);

    LinMaps = LinMaps ./ repmat(sum(sum(LinMaps)),[diameter,diameter,1]);

    LobeMaps = LinMaps;
    
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
 