function generate_null_network_maps(cfg)
%GENERATE_NULL_NETWORK_MAPS Build signed overlap maps for each null dataset.
%
% Synthetic lesion t-maps are thresholded using the same |t| threshold as
% the real-lesion observed network map.

if ~exist(cfg.null_network_dir, 'dir')
    mkdir(cfg.null_network_dir);
end

for null_idx = 1:cfg.num_null
    null_folder = fullfile(cfg.null_tmap_dir, sprintf('null_%05d', null_idx));
    files = dir(fullfile(null_folder, 'glioma_tmap*.mat'));
    num_files = numel(files);

    if num_files == 0
        warning('No t-map files found in %s. Skipping.', null_folder);
        continue;
    end

    positive_count = zeros(cfg.num_voxels, 1);
    negative_count = zeros(cfg.num_voxels, 1);

    for file_idx = 1:num_files
        data = load(fullfile(null_folder, files(file_idx).name), 't_values', 'fdr_mask');
        t_values = data.t_values(:);
        fdr_mask = get_fdr_mask(data, size(t_values));
        fdr_mask = fdr_mask(:);
        positive_count = positive_count + (fdr_mask & (t_values > cfg.t_threshold));
        negative_count = negative_count + (fdr_mask & (t_values < -cfg.t_threshold));
    end

    count = positive_count;
    negative_is_dominant = negative_count > positive_count;
    count(negative_is_dominant) = -negative_count(negative_is_dominant);
    overlap = count / num_files;

    out_file = fullfile(cfg.null_network_dir, sprintf(cfg.null_network_pattern, null_idx));
    save(out_file, 'overlap', 'count', 'positive_count', 'negative_count', 'num_files');
    fprintf('Null %05d processed: %s\n', null_idx, out_file);
end
end

function fdr_mask = get_fdr_mask(data, map_size)
    if isfield(data, 'fdr_mask')
        fdr_mask = data.fdr_mask;
    else
        warning('fdr_mask not found in a t-map file. Using all voxels for backward compatibility.');
        fdr_mask = true(map_size);
    end
end
