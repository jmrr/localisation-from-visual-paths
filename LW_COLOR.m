function LW_COLOR(folder,fname,writepath)

% Generate Signals from frame folder. 

% frame information
D = dir(folder);
D = D(3:end); % discard ./ and ..
numFrames = length(D);
img = imread([folder '/' D(1).name]);
N = size(img,2); % Width
M = size(img,1); % Height
NK = 8; % Number of kernels

% blocks
blocksize = 100;
NBlocks = ceil(numFrames/blocksize);
% lastBlocksize = numFrames-(NBlocks-1)*blocksize;

% Make the sampling tensor, but don't expand it across time or colour
% channels
[x,y] = meshgrid(1:N,1:M);
x = x - mean(x(1,:)); % creates centred x and y coordinate system
y = y - mean(y(:,1));

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
    dp1 = AllUnitVecs*u(k,:)'; dp1 = dp1.*(dp1>0);
    dp1 = reshape(dp1',[M,N]);
    K(:,:,k) = dp1.*Wr1;
    K(:,:,k+NK) = dp1.*Wr2;
end

% Use dot products with directional vectors to define the 
% sampling regime

disp(['Number of Frames: ',num2str(numFrames)]);

for block = 1:NBlocks-1
    x = [];
    for idx = (block-1)*blocksize+1:block*blocksize
        x = cat(4,x,imread([folder '/' D(idx).name]));
    end
    disp(['Read Block #: ',num2str(block)]);
    DescriptorBlocks(:,:,block) = processblock(x,K);
end
% Reshape
[M,N,O] = size(DescriptorBlocks);
DescriptorBlocks = reshape(DescriptorBlocks,[M,N*O]);

% Process last block
x = []; 
for idx = (NBlocks-1)*blocksize+1:numFrames
    x = cat(4,x,imread([folder '/' D(idx).name]));  
end
disp(['Read Block #: ',num2str(NBlocks)]);
DescriptorBlocks = cat(2,DescriptorBlocks,processblock(x,K));

% Construct stack that follows the structure Ndesc x dimDesc x numFrames

DescriptorStack = reshape(DescriptorBlocks,[1 size(DescriptorBlocks)]);

% and save results

save([writepath  fname '_Descriptors'],'DescriptorStack','-v7.3')

function D = processblock(x,K);

y = double(x);
clear x;
[fx,fy,fc,ft] = gradient(y);
clear y;

[M,N,c,NF] = size(fx);
NK = size(K,3);

Kd = reshape(K,[M*N,NK]);

for i = 1:NF
    PartialXFrame = fx(:,:,:,i);
    PartialYFrame = fy(:,:,:,i);
    PartialtFrame = ft(:,:,:,i);
    ip1 = Kd'*reshape(PartialXFrame,[M*N,3]);
    ip2 = Kd'*reshape(PartialYFrame,[M*N,3]);
    ip3 = Kd'*reshape(PartialtFrame,[M*N,3]);
    D(:,i) = [ip1(:);ip2(:);ip3(:)];
end
status = 0;

end % end function processblock

end % function LW_COLOR