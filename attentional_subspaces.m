function subspaces = attentional_subspaces(diameter,rho,alpha_center,alpha,beta) %, r1 , r2 ,mlt
% ATTENTIONAL SUBSPACES 
%
% Author: Ioannis Alexiou, 2013.
% Modified by Jose Rivera, March 2014.  
%   

rows = diameter; % The subspaces will have a square shape specified by the
cols = diameter; % diameter of the shape

subspaces = zeros(rows,cols,24); % Initially, we will have 24 spaces
                                 % 3 scales, 8 orientations each.

[x,y]=meshgrid(-cols/2:(cols/2)-1,-rows/2:(rows/2)-1);

radius = sqrt( (2*(x+0.5)/cols).^2 + (2*(y+0.5)/rows).^2 ); % r = sqrt(x^2+y^2)

i=9;

radius=1.4143-radius;

pow=4;  % 4 with 0.3549 , 6 with 0.3479

Center = exp(-alpha_center*(log(radius/1.41).^pow)); 

subspaces(:,:,1:8) = repmat(Center,1,1,8);

radius=1.4143-radius; % invert the radius

theta = atan2(-y,x); % angular space              

cos_theta = cos(theta);
sin_theta = sin(theta);


for d = 2:3 % Processing of the external radii

    Radial = exp(-alpha*log(radius/rho(d)).^pow);

    for orientations = 0:pi/4:7*pi/4
        
        % Counterclockwise rotation
        dc = cos_theta * cos(orientations) + sin_theta * sin(orientations);    

        ds = sin_theta * cos(orientations) - cos_theta * sin(orientations); 

        dtheta = abs(atan2(ds,dc));                          

        Angular = exp(-beta*(dtheta.^pow));  % Angular component of the pooling function

        subspaces(:,:,i) = (Angular .* Radial); %./(sum( Angular(:).*Radial(:) )); 
                                                % If L1 normalisation to be
                                                % implemented
        i=i+1;

    end

end

end % end function subspaces
