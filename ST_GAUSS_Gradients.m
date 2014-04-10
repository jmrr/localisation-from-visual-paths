function ST_GAUSS_Gradients(seqPath,fname,writepath)

% List files

files = dir([seqPath '*.jpg']); 

% Count number of frames
numFrames = length(files); 

single_frame = imread([seqPath files(1).name]);

Height = size(single_frame, 1);
Width = size(single_frame, 2);

MemSize = Height * Width * numFrames * 4/1e9; % memory in GB

disp([num2str(MemSize) 'GB RAM Memory Occupancy'])

%% Temporal Gaussian, spatial derivative

temporalFilter = fspecial('gauss',[11 1],2);

spatialFilter = imag(gabor(1,0,4,0,1)); % Take the imaginary part of the Gabor 

% Storing the image sequence in memory (valid at low resolutions).

sequence = zeros(Height,Width,numFrames,'single');

for i = 1:numFrames

    I = single(rgb2gray(imread([seqPath files(i).name])));

    sequence(:,:,i) = I; 

end

% Filtering the frames:

% First temporal smoothing
filteredSeqZ = shiftdim(imfilter(shiftdim(sequence,2),temporalFilter','conv'),1);

% Then apply the spatial derivative masks on the filtered sequence
filteredSeqX = imfilter(filteredSeqZ,spatialFilter,'conv');
filteredSeqY = imfilter(filteredSeqZ,spatialFilter','conv');

% Constructing the feature vector:

Mag = sqrt(filteredSeqX.^2+filteredSeqY.^2);

azimuthAngle = atan2(filteredSeqY,filteredSeqX);

% 8 spatial orientations

numAnglesXY = 8;

numChannels = numAnglesXY; % This time there is no elevation angles

channelStack = zeros(Height,Width,numFrames,numChannels,'single');

MemSize = Height*Width*numAnglesXY*numFrames*4/1e9;

disp([num2str(MemSize) 'GB RAM Memory Occupancy of BigChunk'])

for i = 1:numFrames

    quantizedAngles = azimuthAngleQuantizer(Mag(:,:,i),azimuthAngle(:,:,i),numAnglesXY);

    
    channelStack(:,:,i,:) = cat(3,quantizedAngles);

end

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


    