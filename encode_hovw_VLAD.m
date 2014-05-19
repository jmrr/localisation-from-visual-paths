function  encoded_pass = encode_hovw_VLAD(VWords,DescriptorStack)
% ENCODE_HOVW_VLAD(VWords,DescriptorStack)
%    performs vector quantisation (hard assignment) on the descriptor stack
%    for a given pass and dictionary.
%
%   
% Authors: Jose Rivera
%          April, 2014

numFrames = size(DescriptorStack,3);
numDescriptors = size(DescriptorStack,1);
sizeDescriptors = size(VWords,1);
numWords = size(VWords,2);

% Dictionary normalisation and single precision

VWords = single(VWords);

VWords = VWords./repmat(sqrt(sum(VWords.^2,1))+eps,[sizeDescriptors,1]);

% Allocate memory for the encoded pass. Size will be numFrames x numWords

encoded_pass = [];

for f = 1:numFrames

    desc_curr_frame = DescriptorStack(:,:,f); % Current frame descriptors
        
    % Normalise current frame descriptors
    desc_curr_frame = desc_curr_frame ./ ...
        repmat(sqrt(sum(desc_curr_frame.^2,2))+eps,[1,sizeDescriptors]);
    
    % Transpose and convert to single for VLAD encoding
    desc_curr_frame  = single(desc_curr_frame');
    % VLAD requires the data-to-cluster assignments to be passed in. This
    % allows using a fast vector quantization technique (eg kd-tree) as
    % well as switching from soft to hard assignment. [Extract from VLFEAT]
    
    kdtree = vl_kdtreebuild(VWords);
    
    % Obtain the indices of the nearest word to each descriptor
    nn = vl_kdtreequery(kdtree,VWords,desc_curr_frame);
    
    % Create an assignment matrix
        
    assignments = zeros(numWords,numDescriptors,'single');
    
    assignments(sub2ind(size(assignments),single(nn),1:length(nn))) = 1;
    
    % Encode using vl_vlad
    
    HoVW = vl_vlad(desc_curr_frame,VWords,assignments);
    
    encoded_pass(f,:) = HoVW;

end