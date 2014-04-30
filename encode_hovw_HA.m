function  encoded_pass = encode_hovw_HA(VWords,DescriptorStack)
% ENCODE_HOVW_HA(VWords,DescriptorStack)
% performs vector quantisation (hard assignment) on the descriptor stack
% for a given pass and dictionary.
%
%   
% Authors: Jose Rivera and Ioannis Alexiou
%          April, 2014

numFrames = size(DescriptorStack,3);
sizeDescriptors = size(VWords,1);
numWords = size(VWords,2);

% Dictionary normalisation and single precision

VWords = single(VWords);

VWords = VWords./repmat(sqrt(sum(VWords.^2,1))+eps,[sizeDescriptors,1]);

% Allocate memory for the encoded pass. Size will be numFrames x numWords

encoded_pass = zeros(numFrames,numWords,'single');

for f = 1:numFrames

    desc_curr_frame = DescriptorStack(:,:,f); % Current frame descriptors
        
    % Normalise current frame descriptors
    desc_curr_frame = desc_curr_frame ./ ...
        repmat(sqrt(sum(desc_curr_frame.^2,2))+eps,[1,sizeDescriptors]);

    % Project descriptor on dictionary. The maximum projection is the
    % closest word from the vocabulary.
    
    projected_descriptor = desc_curr_frame * VWords;

    [~,words_id] = max(projected_descriptor,[],2);

    HoVW = hist(words_id,1:numWords);

    encoded_pass(f,:) = HoVW;

end