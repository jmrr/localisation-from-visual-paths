function L1_CRBM(seqPath, descrSavePath)
%   CRBM  constructs a single-frame descriptor based on 8-
%   pooler arrangements applied to the outputs of a single layer
%   of a CRBM with linear hidden to visible mapping and binary
%   hidden units. The outputs of this layer are represented as
%   probabilities to the poolers.
%
%   Inputs:
%       - seqPath: an existing path where the sequence images are stored
%       - descriptor_fname: a string representing the descriptor filename to be
%           used for the .mat descriptor data.
%       - writepath: an existing path where the .mat data with the
%           descriptors will be stored
%       - note that this also requires that FBOPT lies within the runtime
%         directory; not sure how this will work out when "batching"
%
%    Authors: Jose Rivera, A.A. Bharath
%             November, 2015
%             V0.1
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
FB = loadcrbmL1('CRBML1Weights');
NUnits = FB.NUnits;
alpha = FB.RecommendedAlpha;
for n = 1:numFrames
    
    I = rgb2gray(imread([seqPath files(n).name]));
    
    % LoG prefiltering
    %X = conv2(double(I),fspecial('gaussian',[7,7],2),'same');
    
    % Normalisation for pixel variance !!! DANGEROUS STUFF USED WITHIN
    % the NN community...NEEDS TO BE REPLACED AT SOME STAGE BY SENSIBLE
    % NORMALISATION LIMITS
    %X = X./sqrt(mean(mean(X.^2)));
    X = double(I)/double(max(I(:)));
    
    Raw = zeros(size(I,1),size(I,2),NUnits);
    
    
    % Compute linear convolution
    for k = 1:NUnits
        Raw(:,:,k) = conv2(X,FB.W(:,:,k),'same') + FB.B(k);
    end
    
    % For debugging, convert to e(actity)
    % TO DO: Figure out why that extra 0.1 factor is required....
    % Hypothesis: there is something still not quite right in the 
    % scaling of the distributions during learning
    eRaw = exp(0.1*alpha*Raw);
    
    % Apply non-linear activations
    if (hasCUDA)
        pactivity = gpuArray.zeros(size(I,1),size(I,2),NUnits);
        for k = 1:NUnits
            pactivity(:,:,k) = gpuArray(eRaw(:,:,k))./(1+conv2(eRaw(:,:,k),sum(LMs,3),'same'));
        end
    else
        pactivity = zeros(size(I,1),size(I,2),NUnits);

        for k = 1:NUnits
            pactivity(:,:,k) = eRaw(:,:,k)./(1+conv2(eRaw(:,:,k),sum(LMs,3),'same'));
        end
    end
    
    % Ensure nothing > 1 - required because pooler is not normalised.
  %  pactivity = pactivity/(max(pactivity(:)));
    
    % Create the sampling grids
    step = 3;
    emptyImg = zeros(size(I,1),size(I,2));
    [Grid,Y,X,LinSize] = MakeGrids(emptyImg,step);
    
    if(hasCUDA)
        DenseMag = PoolingLayer(emptyImg,gpuArray(pactivity),LMs,LinSize,Y,X, hasCUDA);
    else
        DenseMag = PoolingLayer(emptyImg,pactivity,LMs,LinSize,Y,X, hasCUDA);
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

function DM = PoolingLayer(I,scale_space,LMap,LinSize,Y,X, hasCUDA)

NumAttr = 9;
NumGrads = 16;

if(hasCUDA)
    DenseMag = gpuArray.zeros(size(I,1),size(I,2),NumAttr*NumGrads);
else
    DenseMag = zeros(size(I,1),size(I,2),NumAttr*NumGrads);
end

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
