% Multipol analysis
%
% This script runs a retinotopy analysis for computing the BOLD amplitude
% from a phase-encoding paradigm. The analysis includes the following 
% steps: (1) baseline correction, (2) percent signal change (psc) 
% conversion, (3) Fourier analysis, (4) output of metrics at stimulus
% frequency. For baseline correction, a time series with prefix b is 
% written. For psc conversion, a time series with prefix p is written. If 
% the number of cycles <freq> is not an integer, the first cycle fraction 
% is discarded from analysis. Cleanup will delete all generated time series 
% at the end.

% input data
input.data = {
    '/data/pt_01880/test/run/uadata.nii',...
    }; % anticlock
input.tr = 3; % repetition time in s
input.period = 48; % cycle period in s
input.fix = 12; % pre and post run baseline block in s
input.freq = 10.5; % number of cycles
input.hp_cutoff = 144; % cutoff frequency 1/cutoff in Hz
input.psc_cutoff = 50; % threshold value for psc conversion
input.phase_style = 'standard'; % standard | visual

% output specification
name_sess = 'SE_EPI2';
path_output = '/data/pt_01880/test';
cleanup = false;

%%% do not edit below %%%

for i = 1:length(input.data)

    % path and filename
    [path, file, ext] = fileparts(input.data{i});
    
    % run baseline correction
    dh_baseline_correction(...
        input.data{i},...
        input.tr,...
        input.hp_cutoff);

    % run psc conversion
    dh_psc_conversion(...
        fullfile(path,['b' file ext]),...
        input.psc_cutoff);
    
    % run frequency analysis
    dh_retino_fourier(...
        fullfile(path, ['pb' file ext]),...
        input.freq,...
        input.fix,...
        input.period,...
        input.tr);

    % run multipol phase
    dh_multipol_phase(...
        fullfile(path,['rpb' file '_real' ext]),...
        fullfile(path,['rpb' file '_imag' ext]),...
        input.freq,...
        name_sess,...
        path_output, ...
        input.phase_style);
    
    if cleanup
        delete(fullfile(path,['b' file ext]));
        delete(fullfile(path,['pb' file ext]));
        delete(fullfile(path,['rpb' file '_real' ext]));
        delete(fullfile(path,['rpb' file '_imag' ext]));
    end
    
end
