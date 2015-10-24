function ST_descriptor_construction(gradientsFname, descrSavePath, writepath, descProps)
% ST_DESCRIPTOR CONSTRUCTION constructs the space-time descriptors given a
% gradient field previously obtained. A pattern of 17 lobes is applied over
% a patch of 11x11 pixels in spatial extent. The spatial pooling patterns
% are inspired in the DAISY descriptor (Tola, Lepetit and Fua, 2010).
%
%
%   Inputs:
%       - gradients_fname: an existing path where the gradients are stored
%       - descriptor_fname: a string representing the descriptor filename to be
%           used for the .mat descriptor data.
%       - writepath: an existing path where the .mat data with the
%           descriptors will be stored
%       - descProps: descriptor properties, name, dimension, size, ...
%
% Authors: Jose Rivera and Ioannis Alexiou
%          April, 2014
%   

% Load channelStack

filename = [writepath gradientsFname];
load([filename,'.mat']);

Height = size(channelStack,1);
Width = size(channelStack,2);
numFrames = size(channelStack,3);
numChannels = size(channelStack,4);


temporalGaussianFilter = fspecial('gaussian',[11 1],2);

for i = 1:numChannels

    shiftedChannelStack = shiftdim(channelStack(:,:,:,i),2);
    filteredChannelStack = shiftdim(imfilter(shiftedChannelStack,temporalGaussianFilter','conv'),1);
    channelStack(:,:,:,i) = filteredChannelStack;

end

% Create pooling subspaces:

LMs = double(PoolingMappings);

% num_pixels = numel(I);

% Preallocate memory for data structures: grid and descriptor stacks.

GridStack = [];
DescriptorStack = [];

emptyImg = zeros(Height,Width);

% Run for all the frames in the video sequence

for n = 1:numFrames

    [Grid,Y,X,LinSize] = MakeGrids(emptyImg,3);

    DenseMag = PoolingLayer(emptyImg,channelStack(:,:,n,:),LMs,LinSize,Y,X,descProps);

    DenseMag = single( DenseMag ./ repmat(sqrt(sum(DenseMag.^2,2))+eps,[1,size(DenseMag,2)]) );

    DescriptorStack(:,:,n) = DenseMag;
    GridStack(:,:,n) = Grid; 

end

descProps(1).Dimension = size(DescriptorStack,2);

save(descrSavePath,'DescriptorStack','GridStack','descProps','-v7.3')

end % 

function [GridLin,Y,X,LinSize] = MakeGrids(I,step)

Grid = RegularGrid(zeros(size(I)),step,9); % step=3

Y = Grid{1}(:,1);
X = Grid{2}(1,:);

GridLin=[Grid{1}(:),Grid{2}(:)];

LinSize = size(Grid{1},1)*size(Grid{1},2);

end % end Make Grids

function DM = PoolingLayer(I,scale_space,LMap,LinSize,Y,X,descProps)

    NumAttr = 17;
    NumGrads = descProps.QuantizedOrientations;

    DenseMag = zeros(size(I,1),size(I,2),NumAttr*NumGrads,'single');

    for attr = 1:NumAttr

        % Obtain the dense descriptors (1 descriptor per pixel) as the
        % outputs of a dot product at the sampling locations (equivalent
        % to 2D convolution over the whole image in one operation.

        DenseMag(:,:,(attr-1)*NumGrads+(1:NumGrads)) = ... 
        imfilter(scale_space,LMap(:,:,attr),'symmetric','conv') ;

    end

    % Sub-sample according to the dense grid.
    DM = DenseMag;

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