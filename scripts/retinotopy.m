% Retinotopy analysis
%
% This script runs a retinotopy analysis for a phase encoding paradigm
% with rings and wedges. The analysis includes the following steps: 
% (1) baseline correction, (2) percent signal change (psc) conversion, 
% (3) phase calculation, (4) averaging over sessions with opposite stimulus 
% direction. For baseline correction, a time series with prefix b is
% written. For psc conversion, a time series with prefix p is written. Note 
% that the number of cycles <freq> is not an integer value in my runs. The 
% first cycle fraction is discarded from further analysis. We use this to 
% have already initialised activation in the first volume.

% input data
input.pol.data.pos = '/data/pt_01880/test/pol_anticlock/uadata.nii'; % anticlock
input.pol.data.neg = '/data/pt_01880/test/pol_clock/uadata.nii'; % clock
input.pol.tr = 2; % repetition time in s
input.pol.period = 64; % cycle period in s
input.pol.fix = 12; % pre and post run baseline block in s
input.pol.freq = 8.25; % number of cycles
input.pol.hp_cutoff = 192; % cutoff frequency 1/cutoff in Hz
input.pol.psc_cutoff = 50; % threshold value for psc conversion
input.pol.phase_style = 'visual'; % standard | visual

input.ecc.data.pos = '/data/pt_01880/test/ecc_expanding/uadata.nii'; % expanding
input.ecc.data.neg = '/data/pt_01880/test/ecc_contracting/uadata.nii'; % contracting
input.ecc.tr = 2;
input.ecc.period = 32;
input.ecc.fix = 12;
input.ecc.freq = 8.25;
input.ecc.hp_cutoff = 96;
input.ecc.psc_cutoff = 50;
input.ecc.phase_style = 'standard'; % standard | visual

%%% do not edit below %%%

% concatenate all runs into single cell
all_data = {input.pol.data.pos input.pol.data.neg input.ecc.data.pos input.ecc.data.neg};
all_tr = [input.pol.tr input.pol.tr input.ecc.tr input.ecc.tr];
all_hp_cutoff = [input.pol.hp_cutoff input.pol.hp_cutoff input.ecc.hp_cutoff input.ecc.hp_cutoff];
all_psc_cutoff = [input.pol.psc_cutoff input.pol.psc_cutoff input.ecc.psc_cutoff input.ecc.psc_cutoff];
all_freq = [input.pol.freq input.pol.freq input.ecc.freq input.ecc.freq];
all_fix = [input.pol.fix input.pol.fix input.ecc.fix input.ecc.fix];
all_period = [input.pol.period input.pol.period input.ecc.period input.ecc.period];

% prepare path and filename
path = cell(1,length(all_data));
file = cell(1,length(all_data));
ext = cell(1,length(all_data));
for i = 1:length(all_data)
    [path{i}, file{i}, ext{i}] = fileparts(all_data{i});
end

% run baseline correction
for i = 1:length(all_data)
    dh_baseline_correction(...
        all_data{i},...
        all_tr(i),...
        all_hp_cutoff(i));
end

% run psc conversion
for i = 1:length(all_data)
    dh_psc_conversion(...
        fullfile(path{i},['b' file{i} ext{i}]),...
        all_psc_cutoff(i));
end

% run frequency analysis
for i = 1:length(all_data)
    dh_retino_fourier(...
        fullfile(path{i}, ['pb' file{i} ext{i}]),...
        all_freq(i),...
        all_fix(i),...
        all_period(i),...
        all_tr(i));
end

% run phase averaging
[pos_path, pos_file, pos_ext] = fileparts(input.pol.data.pos);
[neg_path, neg_file, neg_ext] = fileparts(input.pol.data.neg);
dh_average_phase(...
    fullfile(pos_path,['rpb' pos_file '_real' pos_ext]),...
    fullfile(pos_path,['rpb' pos_file '_imag' pos_ext]),...
    fullfile(neg_path,['rpb' neg_file '_real' neg_ext]),...
    fullfile(neg_path,['rpb' neg_file '_imag' neg_ext]),...  
    'pol',...
    input.pol.freq, ...
    input.pol.phase_style);

[pos_path, pos_file, pos_ext] = fileparts(input.ecc.data.pos);
[neg_path, neg_file, neg_ext] = fileparts(input.ecc.data.neg);
dh_average_phase(...
    fullfile(pos_path,['rpb' pos_file '_real' pos_ext]),...
    fullfile(pos_path,['rpb' pos_file '_imag' pos_ext]),...
    fullfile(neg_path,['rpb' neg_file '_real' neg_ext]),...
    fullfile(neg_path,['rpb' neg_file '_imag' neg_ext]),...  
    'ecc',...
    input.ecc.freq, ...
    input.ecc.phase_style);
