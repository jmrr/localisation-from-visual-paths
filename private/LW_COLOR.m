function LW_COLOR(seqPath, descrSavePath)
%   LW_COLOR computes the frame level space-time descriptors. They are
%   lightweight (LW) and make use of colour information (COLOR).
%
%   Inputs:
%       - folder: an existing path where the sequence images are stored
%       - desc_fname: a string representing the descriptor filename to be
%           used for the .mat descriptor data.
%       - writepath: an existing path where the .mat data with the
%           descriptors will be stored
%
%   Description: Derivative filters are computed along the x,y and t
%   dimensions on each of the 3 RGB channels. Temporal smoothing with a
%   support of 11 neighbouring frames is applied. Finally, the components
%   of the 3x3 matrix at each of the pixels locations are averaged (pooled) 
%   over 16 spatial regions. The descriptor is thus 144-dimensional
%   (3x3x16).
%   
%
%
% Authors: Anil A. Bharath and Jose Rivera
%          {a.bharath,jose.rivera}@imperial.ac.uk
% Date: April, 2013


% Generate Signals from frame folder. 

% frame information
D = dir(seqPath);
D = D(3:end); % discard ./ and ..
numFrames = length(D);
img = imread([seqPath filesep D(1).name]);
N = size(img,2); % Width
M = size(img,1); % Height
NK = 8; % Number of kernels
% blocks
blocksize = 100;

% Make the sampling tensor, but don't expand it across time or colour
% channels
[x,y] = meshgrid(1:N,1:M);
x = x - mean(x(1,:)); % creates centred x and y coordinate system
y = y - mean(y(:,1));

% Polar coordinates of grid
r = sqrt(x.^2 + y.^2);

theta = atan2(y,x);

u(1,:) = [0 1];
u(2,:) = [1 0];
u(3,:) = [1 1]/sqrt(2);
u(4,:) = [-1 1]/sqrt(2);
u(5,:) = [-1 -1]/sqrt(2);
u(6,:) = [1 -1]/sqrt(2);
u(7,:) = [0 -1];
u(8,:) = [-1 0];

xn = x./r;
yn = y./r;
rho = r./max([M, N]);
Wr1 = rho.^(3.5).*exp(-25*rho);
Wr2 = rho.^(3.5).*exp(-15*rho);


AllUnitVecs = [yn(:),xn(:)];

for k = 1:NK
    dp1 = AllUnitVecs*u(k,:)'; 
    dp1 = dp1.*(dp1>0);
    dp1 = reshape(dp1',[M,N]);
    K(:,:,k) = dp1.*Wr1;
    K(:,:,k+NK) = dp1.*Wr2;
end

% Use dot products with directional vectors to define the 
% sampling regime

disp(['Number of Frames: ',num2str(numFrames)]);

%% BLOCK PROCESSING

NBlocks = ceil(numFrames/blocksize);
% lastBlocksize = numFrames-(NBlocks-1)*blocksize;
x = [];

if NBlocks > 1
    for block = 1:NBlocks-1
        for idx = (block-1)*blocksize+1:block*blocksize
            x = cat(4,x,imread(fullfile(seqPath,D(idx).name)));
        end
        disp(['Read Block #: ',num2str(block)]);
        DescriptorBlocks(:,:,block) = processblock(x,K);
    end
else
    for idx = 1:numFrames
       x = cat(4, x, imread(fullfile(seqPath,D(idx).name)));
    end
   DescriptorBlocks(:,:,1) = processblock(x,K); 
end

% Reshape
[M,N,O] = size(DescriptorBlocks);
DescriptorBlocks = reshape(DescriptorBlocks,[M,N*O]);

if NBlocks > 1
    % Process last block
    x = []; 
    for idx = (NBlocks-1)*blocksize+1:numFrames
        x = cat(4,x,imread([seqPath '/' D(idx).name]));  
    end
    disp(['Read Block #: ',num2str(NBlocks)]);
    DescriptorBlocks = cat(2,DescriptorBlocks,processblock(x,K));

end


% Construct stack that follows the structure Ndesc x dimDesc x numFrames
DescriptorStack = reshape(DescriptorBlocks,[1 size(DescriptorBlocks)]);

% and save results

save(descrSavePath,'DescriptorStack','-v7.3')

end % function LW_COLOR

function D = processblock(x,K)

y = double(x);
clear x;
% fc across colors is not used
% ft uses gradient() default, 1 element spacing in any single direction,
% meaning that it would compute the gradient using the previous frame.
% For each dimension, the gradient is computed across that dimension for 
% all the dimensions of the array
[fx,fy,fc,ft] = gradient(y); 
clear y;

[M,N,c,NF] = size(fx);
NK = size(K,3);

% Unravelling the 16 kernel matrices (one per lobe) into 16 vectors
Kd = reshape(K,[M*N,NK]);

for i = 1:NF
    PartialXFrame = fx(:,:,:,i);
    PartialYFrame = fy(:,:,:,i);
    PartialtFrame = ft(:,:,:,i);
    % Sampling the gradients with the pooler lobes through a weighted
    % average achieved with the matrix product. The reshaping of
    % the partial frames effectively separates the computation per RGB
    % channel.
    ip1 = Kd'*reshape(PartialXFrame,[M*N,3]);
    ip2 = Kd'*reshape(PartialYFrame,[M*N,3]);
    ip3 = Kd'*reshape(PartialtFrame,[M*N,3]);
    D(:,i) = [ip1(:);ip2(:);ip3(:)];
end
status = 0;

end % end function processblock

