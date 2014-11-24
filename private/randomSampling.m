function [pdf] = randomSampling(error_all,NUM_RUNS,NUM_SAMPLES,MAX_ERROR)
% RANDOMSAMPLING is a function that randomly samples a given data structure 
% with all the errors computed for a method, generating the distribution of
% them in a histogram of 100 bins (for now hardcoded.
% 
% Usage: to use within queryRandomisation/queryRandomisationDense
%
% Author: Jose M. Rivera-Rubio (2013).

Nbins = 100;
bins = linspace(0,MAX_ERROR,Nbins);

pdf = [];

for r = 1:NUM_RUNS
    
    imax = length(error_all);

    sampled_error = zeros(NUM_SAMPLES,1);

    for i = 1:NUM_SAMPLES
       sam = randi(imax,1);
       sampled_error(i) = error_all(sam);
    end

    %% Histograms and PDF and CDF
    [h,xc] = hist(sampled_error,bins);
    pdf(r,:) = h/sum(h);
    % plot(pdf)

end % end number of runs


end