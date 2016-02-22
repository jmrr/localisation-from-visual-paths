function plotPoolersMontage
% PLOTPOOLERSMONTAGE plots a montage of the spatial pooling patterns that
% are used to capture local information from dense-like descriptors. A
% total of 17 pooling patterns or "lobes" are generated (2 radii, 8
% orientations and a central "blob").
%
% Author: Jose Rivera, March 2016
%


LobeMaps = poolingMappings;

for i = 1:size(LobeMaps,3)
    subplot(3,6,i)
    imagesc(LobeMaps(:,:,i))
end
colormap(gray(128))

end % end plotPoolersMontage