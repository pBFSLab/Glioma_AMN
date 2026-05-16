function cfg = null_model_config()
%NULL_MODEL_CONFIG Example configuration for size-matched null model testing.

% Lesion table used to estimate the size of each real lesion.
cfg.lesion_table = '/path/to/glioma_core_index_summary.xlsx';
cfg.lesion_table_data_range = 'A2';
cfg.subject_id_col = 1;
cfg.lesion_volume_col = 3;

% Cube approximation parameters.
cfg.volume_tolerance = 5;
cfg.search_half_range = 6;
cfg.cube_dims_xlsx = '/path/to/null_model_with_ID.xlsx';

% Synthetic lesion generation.
cfg.num_null = 10000;
cfg.rng_seed = 20260206;
cfg.brain_mask_nii = '/path/to/norm_8mm.nii.gz';
cfg.synthetic_lesion_dir = '/path/to/null_model_random_indices_iter10000';
cfg.synthetic_grade = 4;
cfg.save_synthetic_xlsx = false;

% Mapping between synthetic lesion indices and rows/columns in rho_z.
cfg.valid_indices_mat = '/path/to/valid_indices_standard_wh.mat';
cfg.valid_indices_variable = 'valid_indices';

% Individual normative functional connectivity matrices.
cfg.gsp_rhoz_dir = '/path/to/GSP_output_rhoz';
cfg.gsp_subject_ids = 1:1000;
cfg.gsp_subject_pattern = 'sub-%04d';
cfg.rhoz_filename = 'rho_z.mat';
cfg.rhoz_variable = 'rho_z';

% Null lesion t-map outputs.
cfg.null_tmap_dir = '/path/to/null_generate_t_map';
cfg.null_tmap_pattern = 'glioma_tmap_null%05d_%s.mat';

% Null network map outputs.
cfg.num_voxels = 9473;
cfg.t_threshold = 5;
cfg.roi_fdr_alpha = 0.01;
cfg.null_network_dir = '/path/to/null_network_results_th5';
cfg.null_network_pattern = 'null_LNM_tmap_null%05d.mat';

% Voxel-wise test and FDR outputs.
cfg.true_network_mat = '/path/to/observed_real_lesion_network_th5.mat';
cfg.true_network_variable = 'overlap';
cfg.null_network_input_pattern = 'null_LNM_tmap_null*.mat';
cfg.output_ratio_mat = '/path/to/nullmodel_true_vs_null_ratio.mat';
cfg.output_fdr_mat = '/path/to/nullmodel_true_vs_null_ratio_pval_FDR.mat';
cfg.fdr_alpha = 1e-4;

end
