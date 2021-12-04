function dh_psc_conversion(input, cutoff_psc, prefix)
% Percent signal change conversion
%
% dh_psc_conversion(input, cutoff_psc, prefix)
%
% Inputs:
%   input      - file name of time series.
%   cutoff_psc - threshold value.
%   prefix     - prefix of output filename.
%
% This function converts a time series in arbitrary units into percent 
% signal change by dividing each voxel time series by its temporal mean and 
% multiplying it by 100. Optionally, all deviations larger than a set value 
% are thresholded. The output time series gets a prefix p to the file name.
%__________________________________________________________________________
% Copyright (C) 2021 Daniel Haenelt

if ~exist('cutoff_psc', 'var')
    cutoff_psc = 50;
end

if ~exist('prefix','var')  
    prefix = 'p';
end

% get fileparts of input
[path, file, ext] = fileparts(input);

% load input time series
data_img = spm_vol(input);
data_array = spm_read_vols(data_img);

% get image dimensions
dim = data_img(1).dim;
nt = length(data_img);

% compute percent signal change
data_array_mean = mean(data_array, 4);
data_array = data_array ./ data_array_mean * 100;

% threshold data
if cutoff_psc
    data_array_max = max(data_array, [], 4);
    data_array_min = min(data_array, [], 4);
    
    data_array_max = repmat(data_array_max, 1, 1, 1, nt);
    data_array_min = repmat(data_array_min, 1, 1, 1, nt);
    
    data_array(data_array_max > 100 + cutoff_psc) = 100 + cutoff_psc;
    data_array(data_array_min < 100 - cutoff_psc) = 100 - cutoff_psc;
end

data_array = data_array - 100;

% write output
for i = 1:nt
  data_img(i).dim = dim;
  data_img(i).fname = fullfile(path, [prefix file ext]);
  spm_write_vol(data_img(i), data_array(:,:,:,i));
end