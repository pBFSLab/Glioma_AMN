clear;
clc;

addpath(fullfile(fileparts(mfilename('fullpath')), '..', 'src', 'matlab'));
addpath(fullfile(fileparts(mfilename('fullpath')), '..', 'config'));

cfg = null_model_config();
voxelwise_null_ratio_test(cfg);
