function FB = loadcrbmL1(PATHTOWEIGHTS)
% TO BE COMMENTED
%
% Created by AAB, November, 2015
%
% Version history: 
%       - None
%

% Determine size of the support with 4 times the Gaussian sigma.
try
    load FBOPT;
catch
    disp('Failed to load CRBM Weights - bailing out');
    error([mfilename,': Failed to load CRBM Weights']);
end
end % End Gabor function

