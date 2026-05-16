clear;
clc;

addpath(fullfile(fileparts(mfilename('fullpath')), '..', 'src', 'matlab'));
addpath(fullfile(fileparts(mfilename('fullpath')), '..', 'config'));

cfg = real_lesion_config();
generate_observed_lesion_network(cfg);
