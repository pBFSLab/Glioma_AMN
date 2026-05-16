function generate_observed_lesion_network(cfg)
%GENERATE_OBSERVED_LESION_NETWORK Generate observed glioma network overlap.
%
% ROI-specific t-maps are thresholded at |t| > cfg.t_threshold. At each
% voxel, the output stores the dominant overlap ratio: positive values for
% positive RSFC overlap and negative values for anti-correlated overlap.

files = dir(fullfile(cfg.output_tmap_dir, cfg.input_tmap_pattern));
num_lesions = numel(files);

if num_lesions == 0
    error('No t-map files found in %s.', cfg.output_tmap_dir);
end

positive_count = zeros(1, cfg.num_voxels);
negative_count = zeros(1, cfg.num_voxels);

for file_idx = 1:num_lesions
    file_path = fullfile(cfg.output_tmap_dir, files(file_idx).name);
    data = load(file_path, 't_values', 'fdr_mask');
    t_values = data.t_values;
    fdr_mask = get_fdr_mask(data, size(t_values));

    positive_count = positive_count + (fdr_mask & (t_values > cfg.t_threshold));
    negative_count = negative_count + (fdr_mask & (t_values < -cfg.t_threshold));
end

count = positive_count;
negative_is_dominant = negative_count > positive_count;
count(negative_is_dominant) = -negative_count(negative_is_dominant);

overlap = count / num_lesions;

output_dir = fileparts(cfg.output_network_mat);
if ~isempty(output_dir) && ~exist(output_dir, 'dir')
    mkdir(output_dir);
end

save(cfg.output_network_mat, 'overlap', 'count', 'positive_count', ...
    'negative_count', 'num_lesions');

fprintf('Saved observed lesion network: %s\n', cfg.output_network_mat);

end

function fdr_mask = get_fdr_mask(data, map_size)
    if isfield(data, 'fdr_mask')
        fdr_mask = data.fdr_mask;
    else
        warning('fdr_mask not found in a t-map file. Using all voxels for backward compatibility.');
        fdr_mask = true(map_size);
    end
end
