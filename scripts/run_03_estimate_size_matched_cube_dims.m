clear;
clc;

addpath(fullfile(fileparts(mfilename('fullpath')), '..', 'src', 'matlab'));
addpath(fullfile(fileparts(mfilename('fullpath')), '..', 'config'));

cfg = null_model_config();
estimate_size_matched_cube_dims(cfg);
