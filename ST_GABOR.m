function [descProps] = ST_GABOR(seqPath,fname,writepath)

% List files

files = dir([seqPath '*.jpg']); 

% Count number of frames
numFrames = length(files); 

single_frame = imread([seqPath files(1).name]);

Height = size(single_frame, 1);
Width = size(single_frame, 2);

MemSize = Height * Width * numFrames * 4/1e9; % memory in GB

disp([num2str(MemSize) 'GB RAM Memory Occupancy'])

% Declare descriptor properties
descProps = struct('Name',{},'Dimension',{},'SpatialSize',{},...
    'TemporalSmoothingSize',{},'GaussianStd',{},'QuantizedOrientationsXY',{},...
    'QuantizedElevations',{},'QuantizedOrientations',{});


%% Anti-simmetric complex Gabor filters: spatial and temporal
% gabor(sigma,orient,lambda,phase,aspect)

spatialFilter = imag(gabor(1,0,4,0,1)); % Take the imaginary part of the Gabor 
spatialFilter = spatialFilter(3,:);            % Take the max component x-dir
spatialFilter = spatialFilter ./ sqrt(sum(spatialFilter(:).^2)) ; % L2 normalisation

temporalFilter = imag(gabor(2,0,8,0,1));
temporalFilter = temporalFilter(5,:);
temporalFilter = temporalFilter ./ sqrt(sum(temporalFilter(:).^2)) ;

% Storing the image sequence in memory (valid at low resolutions).

sequence = zeros(Height,Width,numFrames,'single');

for i = 1:numFrames

    I = single(rgb2gray(imread([seqPath files(i).name])));

    sequence(:,:,i) = I; 

end

% Filtering the frames:

filteredSeqX = imfilter(sequence,spatialFilter,'conv');
filteredSeqY = imfilter(sequence,spatialFilter','conv');
filteredSeqZ = shiftdim(imfilter(shiftdim(sequence,2),temporalFilter','conv'),1);

% Constructing the feature vector:

Mag = sqrt(filteredSeqX.^2+filteredSeqY.^2+filteredSeqZ.^2);

azimuthAngle = atan2(filteredSeqY,filteredSeqX);

elevAngle = acos(filteredSeqZ./(Mag+eps));

% 8 spatial orientations + 5 temporal elevations = 13.

numAnglesXY = 8;
numElevations = 5;

numChannels = numAnglesXY + numElevations;

% BigChunck = zeros(Height,Width,13*numFrames,'single');
channelStack = zeros(Height,Width,numFrames,numChannels,'single');

MemSize = Height*Width*13*numFrames*4/1e9;

disp([num2str(MemSize) 'GB RAM Memory Occupancy of channelStack'])

for i = 1:numFrames

    t1 = azimuthAngleQuantizer(Mag(:,:,i),azimuthAngle(:,:,i),numAnglesXY);
    t2 = elevationAngleQuantizer(Mag(:,:,i),elevAngle(:,:,i));

%     BigChunck(:,:,(i-1)*13+(1:13)) = cat(3,t1,t2);  
    channelStack(:,:,i,:) = cat(3,t1,t2);

end

% Complete descProps and save

descProps(1).Name = 'ST_GABOR: Anti-simmetric complex Gabor filters: spatial and temporal';
descProps(1).SpatialSize = size(spatialFilter);
descProps(1).TemporalSmoothingSize = size(temporalFilter);
descProps(1).QuantizedOrientationsXY = numAnglesXY;
descProps(1).QuantizedElevations = numElevations;
descProps(1).QuantizedOrientations = numAnglesXY+numElevations;

save([writepath fname],'channelStack','-v7.3')


function Channels = azimuthAngleQuantizer(Mag,AngleEst,numAnglesXY)

 angstep = 2*pi/numAnglesXY;

 angles=0:angstep:2*pi-angstep;

    for a=1:length(angles)
    %     compute each orientation channel
        tmp = cos(AngleEst - angles(a)).^9;
        tmp = tmp .* (tmp > 0);

    %     weight by magnitude
       Channels(:,:,a) = tmp .* Mag;

    end

function Channels = elevationAngleQuantizer(Mag,AngleEst)

angles = 0:pi/4:pi;

for a=1:length(angles)
%     compute each orientation channel
    tmp = cos(AngleEst - angles(a)).^9;
    tmp = tmp .* (tmp > 0);

%     weight by magnitude
   Channels(:,:,a) = tmp .* Mag;

end
    