function [encoded_pass] = encode_hovw_LLC_sparse(VWords,DescriptorStack)
% LLC_CODING_SPARSE  runs Jinjun Wang's LLC coding
%   LLC_CODING_SPARSE(VWords,DescriptorStack) has the following parameters
%   Inputs:
%       - VWords: d x M codebook, M entries in a d-dim space -
%       DescriptorStack: F-dim cell array, each of the elements represent
%       one of the F frames with N data points in a d- dim space.
%   
%   Outputs:
%       - encoded_pass: F x M, F frames encoded with M words.
%
%   Copyright 2014 Jose Rivera @ Imperial College London.

addpath('./lib'); % Add path with LLC code

% Data parameters

numFrames = size(DescriptorStack,2);
sizeDescriptors = size(VWords,1);
numWords = size(VWords,2);

% LLC parameters
knn =  5; % Nearest neighbours
beta = 1e-6;

% Dictionary normalisation and single precision

VWords = single(VWords);

VWords = VWords./repmat(sqrt(sum(VWords.^2,1))+eps,[sizeDescriptors,1]);

% Allocate memory for the encoded pass. Size will be numFrames x numWords

encoded_pass = [];

for f = 1:numFrames

    desc_curr_frame = DescriptorStack{f}; % Current frame descriptors
        
    % Normalise current frame descriptors
    desc_curr_frame = single(desc_curr_frame) ./ ...
        repmat(sqrt(sum(desc_curr_frame.^2,1))+eps,[sizeDescriptors,1]);

    % Apply LLC coding to obtain the coefficients for the current
    % descriptor
    
    [Coeff] = LLC_coding_appr(VWords', desc_curr_frame', knn, beta);

    HoVW = max(Coeff,[],1);
    
    encoded_pass(f,:) = HoVW;

end
