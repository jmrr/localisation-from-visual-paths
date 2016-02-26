function gb = gabor(sigma,orient,lambda,phase,aspect)
% GABOR produces a numerical approximation to 2D Gabor function.
% Parameters:
% sigma  = standard deviation (width) of the Gaussian envelope, this
%          in-turn controls the size of the result (pixels). Size of the
%          output Gabor filter will be (4*sigma+1)x(4*sigma+1).
% orient = orientation of the Gabor from the vertical (degrees): the
%          direction of the carrier since x_theta and y_theta are rotated
%          by theta.
% lambda = the wavelength of the carrier (pixels).
% phase  = the phase offset of the carrier(degrees)
% aspect = aspect ratio of Gaussian envelope (0 = no modulation over "width" of
%          sin wave, 1 = circular symmetric envelope). Aspect can also be
%          seen as the amount the kernel is "stretched" either along or
%          across the kernel wave pattern, or ellipticity of the support.
%
% Example:
%   gabor(2,45,4,0,1)
%
% Old parameters:
% beta   =  octaves, bandwidth of gabor (0.62 0.8 1 1.2 1.5)
% sigma = wavel*((2^beta+1)/(2^beta-1))*sqrt(log(2)/2)/pi;
% sigma = wavel*((2^beta+1)/(2^beta-1))/(2*pi);
%

% Created by Ioannis Alexiou (2012-2013)
% Modified by Jose Rivera (2013-2014)
%
% Version history: 
%       - March 2014: changed some definitions and added comments
%

% Determine size of the support with 4 times the Gaussian sigma.

number_stds = 4;

sz = fix(number_stds*sigma./max(0.2,aspect));

if mod(sz,2)==0, 
    sz = sz+1;
end

%Create the support grid.

[x,y] = meshgrid(-fix(sz/2):fix(sz/2),-fix(sz/2):fix(sz/2));
 
% Rotation of the carrier

orient = orient*pi/180; % theta in gradients

x_theta = x*cos(orient) + y*sin(orient);
y_theta = -x*sin(orient)+ y*cos(orient);


% % Alternative rotation matrix
% rot_matrix = [cos(orient) -sin(orient); sin(orient) cos(orient)];
% 
% rot_carrier = rot_matrix*[x,y]';
% 
% x_theta = reshape(rot_carrier(:,1),size(x));
% y_theta = reshape(rot_carrier(:,2,size(y)));


phase = phase*pi/180;

% The complex Gabor

gb = exp(-((x_theta.^2/sigma^2)+(aspect^2*y_theta.^2/sigma^2))).*exp(1i*(2*pi*x_theta/lambda+phase)); 

% Remove DC component: this is a requirement in any filter kernel used for
% convolution, i.e. sum(gb) has to be close to 0.
gb = gb - mean(gb(:));

% L2 Wavelet Normalization, consistent to normalization in image processing masks
gb = gb ./  sum( abs(gb(:)) ) ;

end % End Gabor function

