function voxelwise_null_ratio_test(cfg)
%VOXELWISE_NULL_RATIO_TEST Compare observed map with null maps voxel-wise.

true_data = load(cfg.true_network_mat, cfg.true_network_variable);
true_overlap = true_data.(cfg.true_network_variable);
true_overlap = true_overlap(:);
num_voxels = numel(true_overlap);

null_files = dir(fullfile(cfg.null_network_dir, cfg.null_network_input_pattern));
num_null = numel(null_files);

if num_null == 0
    error('No null network files found in %s.', cfg.null_network_dir);
end

null_overlap = zeros(num_voxels, num_null);
for null_idx = 1:num_null
    tmp = load(fullfile(cfg.null_network_dir, null_files(null_idx).name), 'overlap');
    null_overlap(:, null_idx) = tmp.overlap(:);
end

ratio = zeros(num_voxels, 1);
pos_idx = true_overlap >= 0;
neg_idx = true_overlap < 0;

ratio(pos_idx) = sum(true_overlap(pos_idx) > null_overlap(pos_idx, :), 2) ./ num_null;
ratio(neg_idx) = sum(true_overlap(neg_idx) < null_overlap(neg_idx, :), 2) ./ num_null;

output_dir = fileparts(cfg.output_ratio_mat);
if ~isempty(output_dir) && ~exist(output_dir, 'dir')
    mkdir(output_dir);
end
save(cfg.output_ratio_mat, 'ratio', 'num_null');
fprintf('Voxel-wise ratio saved to: %s\n', cfg.output_ratio_mat);
end
