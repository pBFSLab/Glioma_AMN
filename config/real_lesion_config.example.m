function cfg = real_lesion_config()
%REAL_LESION_CONFIG Example configuration for real-lesion network mapping.

% Input lesion table. The table must contain one row per lesion and voxel
% indices from lesion_index_start_col to the final column.
cfg.lesion_table = '/path/to/core_index_summary.xlsx';
cfg.lesion_table_range = 'A1';
cfg.grade_filter = 4;
cfg.subject_id_col = 1;
cfg.grade_col_name = 'Grade';
cfg.lesion_index_start_col = 4;

% Mapping between whole-brain voxel indices and rows/columns in rho_z.
cfg.valid_indices_mat = '/path/to/valid_indices_standard_wh_MNI8mm.mat';
cfg.valid_indices_variable = 'valid_indices';

% Normative functional connectivity matrices.
cfg.gsp_rhoz_dir = '/path/to/GSP_output_rhoz';
cfg.gsp_subject_ids = 1:1000;
cfg.gsp_subject_pattern = 'sub-%04d';
cfg.rhoz_filename = 'rho_z.mat';
cfg.rhoz_variable = 'rho_z';

% Analysis parameters.
cfg.num_voxels = 9473;
cfg.t_threshold = 5;
cfg.roi_fdr_alpha = 0.01;

% Outputs.
cfg.output_tmap_dir = '/path/to/real_lesion_tmaps';
cfg.output_tmap_pattern = 't_map_grade%d_%s.mat';
cfg.input_tmap_pattern = 't_map_grade*.mat';
cfg.output_network_mat = '/path/to/observed_real_lesion_network_th5.mat';

end
