clear;
clc;

addpath(fullfile(fileparts(mfilename('fullpath')), '..', 'src', 'matlab'));
addpath(fullfile(fileparts(mfilename('fullpath')), '..', 'config'));

cfg = null_model_config();
generate_null_network_maps(cfg);
