function dh_multipol_phase(input_real, input_imag, freq, name_sess, ...
    path_output, phase_style)
% Multipol phase
%
% dh_multipol_phase(input_real, input_imag, freq, name_sess, ...
%    path_output)
%
% Inputs:
%   input_real  - real part of fft.
%   input_imag  - imaginary part of.
%   freq        - number of cycles.
%   name_sess   - name of session included in the basename.
%   path_output - path where output is saved.
%   phase_style - retinotopy styles (standard, visual).
%
% This function takes the real and imaginary parts from the time series
% fft and computes several metrics. Similar to Dumoulin et al. 2017, we 
% compute a coherence estimate of the voxel respose at stimulus frequency 
% by taking the amplitude and dividing it by the root mean square of the 
% one-sided power spectrum. Other measures as F-statistics are computed by 
% taking the amplitude and dividing it by the mean amplitude of the rest of 
% the frequency spectrum. Based on this, the voxel population can be 
% thresholded to investigate different subpopulations. To run this 
% function, the number of runs has to be specified to choose an appropriate 
% results folder location. Phase maps can be encoded by two different 
% styles (standard, visual). The polar angle map with style 'visual' 
% thereby matches the convention in Noah Benson's neuropythy library.
%
% Standard:
%   left hemisphere: -90->+90 (UVM -> RHM -> LVM)
%   right hemisphere: -90->-180,+180->90 (UVM -> LHM -> LVM)
% Visual:
%   left hemisphere: 0->180 (UVM -> RHM -> LVM)
%   right hemisphere: 0->-180 (UVM -> LHM -> LVM)
%__________________________________________________________________________
% Copyright (C) 2021 Daniel Haenelt

if ~exist('phase_style', 'var')
    phase_style = 'standard';
end

phase_style_list = {'standard', 'visual'};
if ~any(strcmp(phase_style_list, phase_style))
    error('Error. Unknown phase_style!');
end

% parameters
% freq_ignored is a vector containing the frequencies that should be
% ignored when calculating the denominator.
freq = floor(freq);
freq_ignored = [];
%freq_ignored = [0:1 freq-1 freq freq+1];

% define output paths
[~, name_run, ~] = fileparts(fileparts(input_real));
path_a = fullfile(path_output,'results','a','native');
path_c = fullfile(path_output,'results','c','native');
path_f = fullfile(path_output,'results','f','native');
path_imag = fullfile(path_output,'results','imag','native');
path_real = fullfile(path_output,'results','real','native');
path_phase = fullfile(path_output,'results','phase','native');
path_snr = fullfile(path_output,'results','snr','native');

if ~exist(path_a,'dir') 
    mkdir(path_a); 
end

if ~exist(path_c,'dir') 
    mkdir(path_c); 
end

if ~exist(path_f,'dir') 
    mkdir(path_f); 
end

if ~exist(path_imag,'dir') 
    mkdir(path_imag); 
end

if ~exist(path_real,'dir') 
    mkdir(path_real); 
end

if ~exist(path_phase,'dir') 
    mkdir(path_phase); 
end

if ~exist(path_snr,'dir') 
    mkdir(path_snr); 
end

% load input
data_img = spm_vol(input_imag); % imaginary
data_imag_array = spm_read_vols(data_img);
data_img = spm_vol(input_real); % real
data_real_array = spm_read_vols(data_img);

% get image dimension
nt = length(data_img);

% mean power over all (considered) frequencies
pw = sqrt(data_real_array.^2+data_imag_array.^2); 
mfs = 1:round(nt/2);
mfs = mfs(~ismember(mfs, freq_ignored+1));
sumpw = sqrt(nansum(pw(:,:,:,mfs).^2,4));
mpw = nanmean(pw(:,:,:,mfs),4); 
mstd = nanstd(pw(:,:,:,mfs),0,4);

% real and imaginary parts at stimulus frequency
data_imag_freq_array = squeeze(data_imag_array(:,:,:,freq+1));
data_real_freq_array = squeeze(data_real_array(:,:,:,freq+1));   

% data at cycle frequency
A_array = sqrt(data_real_freq_array.^2+data_imag_freq_array.^2); % amplitude
F_array = A_array ./ mpw * 100; % F-statistic 
snr_array = A_array ./ mstd; % SNR
coherence_array = A_array ./ sumpw; % coherence

% transform to phases
if strcmp(phase_style, 'standard')
    pha_array = atan2(data_imag_freq_array,data_real_freq_array)/pi*180; % phase in degrees
end

if strcmp(phase_style, 'visual')
    pha_array = (atan2(-1,0) - atan2(data_imag_freq_array,data_real_freq_array))/pi*180;
end

pha_array = mod(pha_array,360); % phases between 0 and 360
pha_array = pha_array - 180;  % phases between -180 and +180

% change NaN in background to 0
data_real_freq_array(isnan(data_real_freq_array)) = 0;
data_imag_freq_array(isnan(data_imag_freq_array)) = 0;
pha_array(isnan(pha_array)) = 0;
A_array(isnan(A_array)) = 0;
F_array(isnan(F_array)) = 0;
snr_array(isnan(snr_array)) = 0;
coherence_array(isnan(coherence_array)) = 0;

% save niftis
nhdr = data_img(1);

if isempty(name_sess)
    nhdr.fname = fullfile(path_real,['real_' name_run '.nii']);
    spm_write_vol(nhdr,data_real_freq_array);

    nhdr.fname = fullfile(path_imag,['imag_' name_run '.nii']);
    spm_write_vol(nhdr,data_imag_freq_array);

    nhdr.fname = fullfile(path_phase,['phase_' name_run '.nii']);
    spm_write_vol(nhdr,pha_array);

    nhdr.fname = fullfile(path_a,['a_' name_run '.nii']);
    spm_write_vol(nhdr,A_array);

    nhdr.fname = fullfile(path_f,['f_' name_run '.nii']);
    spm_write_vol(nhdr,F_array);

    nhdr.fname = fullfile(path_snr,['snr_' name_run '.nii']);
    spm_write_vol(nhdr,snr_array);

    nhdr.fname = fullfile(path_c,['c_' name_run '.nii']);
    spm_write_vol(nhdr,coherence_array);
else
    nhdr.fname = fullfile(path_real,['real_' name_sess '_' name_run '.nii']);
    spm_write_vol(nhdr,data_real_freq_array);

    nhdr.fname = fullfile(path_imag,['imag_' name_sess '_' name_run '.nii']);
    spm_write_vol(nhdr,data_imag_freq_array);

    nhdr.fname = fullfile(path_phase,['phase_' name_sess '_' name_run '.nii']);
    spm_write_vol(nhdr,pha_array);

    nhdr.fname = fullfile(path_a,['a_' name_sess '_' name_run '.nii']);
    spm_write_vol(nhdr,A_array);

    nhdr.fname = fullfile(path_f,['f_' name_sess '_' name_run '.nii']);
    spm_write_vol(nhdr,F_array);

    nhdr.fname = fullfile(path_snr,['snr_' name_sess '_' name_run '.nii']);
    spm_write_vol(nhdr,snr_array);

    nhdr.fname = fullfile(path_c,['c_' name_sess '_' name_run '.nii']);
    spm_write_vol(nhdr,coherence_array);
end
