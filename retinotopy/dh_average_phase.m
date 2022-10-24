function dh_average_phase(pos_real, pos_imag, neg_real, neg_imag, ...
    name_sess, freq, phase_style)
% Average phase
%
% dh_average_phase(pos_real, pos_imag, neg_real, neg_imag, ...
%    name_sess, freq, phase_style)
%
% Inputs:
%   pos_real    - real part of fft in positive direction.
%   pos_imag    - imaginary part of fft in positive direction.
%   neg_real    - real part of fft in negative direction.
%   neg_imag    - imaginary part of fft in negative direction.
%   name_sess   - name of session.
%   freq        - number of cycles.
%   phase_style - retinotopy styles (standard, visual).
%
% This function takes the real and imaginary parts from the time series fft
% of stimuli pairs in positive and negative directions. Both directions are
% averaged to compensate for the hemodynamic lag. Output files are saved in
% a created output folder with prefix s. Phase maps can be encoded by two
% different styles (standard, visual). The polar angle map with style
% 'visual' thereby matches the convention in Noah Benson's neuropythy 
% library.
%
% Standard:
%   left hemisphere: -90->-180,+180->90 (UVM -> LHM -> LVM)
%   right hemisphere: -90->+90 (UVM -> RHM -> LVM)
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
% ignored when calculating the coherence values.
freq = floor(freq);
freq_ignored = [0:1 freq-1 freq freq+1];

% output folder is taken from the first entry of the function
path_output = fullfile(fileparts(fileparts(pos_real)),'avg','native');
if ~exist(path_output,'dir') 
    mkdir(path_output); 
end

% load input
data_img = spm_vol(neg_imag); % imaginary
c_imag = spm_read_vols(data_img);
data_img = spm_vol(neg_real); % real
c_real = spm_read_vols(data_img);
data_img = spm_vol(pos_imag); % imaginary
a_imag = spm_read_vols(data_img);
data_img = spm_vol(pos_real); % real
a_real = spm_read_vols(data_img);

% flip imaginary part of negative direction
c_imag = -c_imag;

% get image dimension
dim = data_img.dim;
nt = length(data_img);

% average different directions
all_real = NaN([dim nt 2]);
all_imag = NaN([dim nt 2]);
all_real(:,:,:,:,1) = c_real;
all_real(:,:,:,:,2) = a_real;
all_imag(:,:,:,:,1) = c_imag;
all_imag(:,:,:,:,2) = a_imag;
avg_real = mean(all_real,5);
avg_imag = mean(all_imag,5);

% mean power over all (considered) frequencies
avg_pw = sqrt(avg_real.^2+avg_imag.^2); 
mfs = 1:round(nt/2);
mfs = mfs(~ismember(mfs, freq_ignored+1));
mpw = nanmean(avg_pw(:,:,:,mfs),4); 
mstd = nanstd(avg_pw(:,:,:,mfs),0,4);

% real and imaginary parts at stimulus frequency
avg_imag_freq = squeeze(avg_imag(:,:,:,freq+1));
avg_real_freq = squeeze(avg_real(:,:,:,freq+1));   

% data at cycle frequency
avg_A = sqrt(avg_real_freq.^2+avg_imag_freq.^2); % amplitude
avg_F = avg_A ./ mpw * 100; % F-statistic 
avg_snr = avg_A ./ mstd; % SNR

% transform to phases
if strcmp(phase_style, 'standard')
    avg_pha = atan2(avg_imag_freq,avg_real_freq)/pi*180; % phase in degrees
end

if strcmp(phase_style, 'visual')
    avg_pha = (atan2(-1,0) - atan2(avg_imag_freq,avg_real_freq))/pi*180;
end

avg_pha = mod(avg_pha,360); % phases between 0 and 360
avg_pha = avg_pha - 180;  % phases between -180 and +180

% change NaN in background to 0
avg_real_freq(isnan(avg_real_freq)) = 0;
avg_imag_freq(isnan(avg_imag_freq)) = 0;
avg_pha(isnan(avg_pha)) = 0;
avg_A(isnan(avg_A)) = 0;
avg_F(isnan(avg_F)) = 0;
avg_snr(isnan(avg_snr)) = 0;

% save niftis
nhdr = data_img(1);
nhdr.fname = fullfile(path_output,[name_sess '_real_avg.nii']);
spm_write_vol(nhdr,avg_real_freq);

nhdr.fname = fullfile(path_output,[name_sess '_imag_avg.nii']);
spm_write_vol(nhdr,avg_imag_freq);

nhdr.fname = fullfile(path_output,[name_sess '_phase_avg.nii']);
spm_write_vol(nhdr,avg_pha);

nhdr.fname = fullfile(path_output,[name_sess '_a_avg.nii']);
spm_write_vol(nhdr,avg_A);

nhdr.fname = fullfile(path_output,[name_sess '_f_avg.nii']);
spm_write_vol(nhdr,avg_F);

nhdr.fname = fullfile(path_output,[name_sess '_snr_avg.nii']);
spm_write_vol(nhdr,avg_snr);
