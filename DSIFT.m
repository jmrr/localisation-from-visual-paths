function DSIFT(seqPath,desc_fname,writepath,varargin)
%   DSIFT computes the dense-SIFT descriptors on a set of images found in a
%       given path. Requires VLFEAT (http://www.vlfeat.org/)
%   
%   Usage:
%   DSIFT(seqPath,desc_fname,writepath) generates the dense SIFT descriptor
%   with a default step size of 3 pixels.
%
%   Inputs:
%       - seqPath: an existing path where the sequence images are stored
%       - desc_fname: a string representing the descriptor filename to be
%           used for the .mat descriptor data.
%       - writepath: an existing path where the .mat data with the
%           descriptors will be stored
%   DSIFT(seqPath,desc_fname,writepath,STEP) allows the selection of a custom
%       step size
%
% Author: Ioannis Alexiou, 2013.
% Modified by Jose Rivera, April 2014.  
%

files = dir([seqPath '*.jpg']);

% num Frames
numFrames = length(files); 

single_frame = imread([seqPath files(1).name]);

Height = size(single_frame, 1);
Width = size(single_frame, 2);

MemSize = Height * Width * numFrames * 4/1e9; % memory in GB

disp([num2str(MemSize) 'GB RAM Memory Occupancy'])

% Preallocate memory for data structures: grid and descriptor stacks.

GridStack = [];
DescriptorStack = [];

% SIFT descriptor parameters

if nargin < 4 % Default case
    step = 3; % Step between descriptor centres, or grid step size.
else 
    step = varargin{1};
end

smoothingSigma = 1.2; % smoothingSigma = (binSize/magnif)^2 - .25; where 
                      % magnif is the relationship between keypoint scale
                      % and bin size. By default, magnif is 3.00
                      
binSize = 3; 

for i = 1:numFrames

    I = single(rgb2gray(imread([seqPath files(i).name])));
    
    Is = vl_imsmooth(I,smoothingSigma);
    
    [Grid,Descriptors] = vl_dsift(Is,'step',step,'size',binSize,'FloatDescriptors');

    Descriptors = Descriptors';

    normalisedDescriptors = Descriptors ./ repmat(sqrt(sum(Descriptors.^2,2))+eps...
        ,[1,size(Descriptors,2)]);

    GridStack = cat(3,GridStack,single(Grid'));
    DescriptorStack = cat(3,DescriptorStack,single(normalisedDescriptors));

end

save([writepath  desc_fname '_Descriptors'],'DescriptorStack','GridStack','-v7.3')

end % end DSIFT function
