function compute_null_lesion_tmaps(cfg)
% COMPUTE_NULL_LESION_TMAPS Compute synthetic-lesion RSFC t-maps.
%
% This mirrors the real-lesion t-map procedure: for each synthetic lesion,
% ROI-to-whole-brain Fisher-z connectivity is extracted from each normative
% GSP participant and voxel-wise one-sample t-values are computed across
% participants.

if ~exist(cfg.null_tmap_dir, 'dir')
    mkdir(cfg.null_tmap_dir);
end

valid_contents = load(cfg.valid_indices_mat, cfg.valid_indices_variable);
valid_indices = valid_contents.(cfg.valid_indices_variable);

for null_idx = 1:cfg.num_null
    fprintf('\n=== Processing null %05d / %05d ===\n', null_idx, cfg.num_null);

    null_mat = fullfile(cfg.synthetic_lesion_dir, sprintf('null_%05d.mat', null_idx));
    tmp = load(null_mat, 'null_data');
    null_data = tmp.null_data;

    out_folder = fullfile(cfg.null_tmap_dir, sprintf('null_%05d', null_idx));
    if ~exist(out_folder, 'dir')
        mkdir(out_folder);
    end

    for lesion_idx = 1:numel(null_data)
        sub_id = null_data(lesion_idx).Subid;
        sub_indices = null_data(lesion_idx).lin_idx;

        [~, indices_in_valid] = ismember(sub_indices, valid_indices);
        roi_rows = indices_in_valid(indices_in_valid > 0);

        if isempty(roi_rows)
            warning('No valid voxels for lesion %s in null %d.', sub_id, null_idx);
            continue;
        end

        all_subject_fc = zeros(numel(cfg.gsp_subject_ids), cfg.num_voxels);
        valid_subject = false(numel(cfg.gsp_subject_ids), 1);

        for subject_idx = 1:numel(cfg.gsp_subject_ids)
            gsp_id = cfg.gsp_subject_ids(subject_idx);
            subject_dir = sprintf(cfg.gsp_subject_pattern, gsp_id);
            mat_file = fullfile(cfg.gsp_rhoz_dir, subject_dir, cfg.rhoz_filename);

            if exist(mat_file, 'file') ~= 2
                warning('Missing GSP rho-z file: %s', mat_file);
                continue;
            end

            mat_data = load(mat_file, cfg.rhoz_variable);
            rho_z = mat_data.(cfg.rhoz_variable);
            mean_roi_fc = mean(rho_z(roi_rows, :), 1, 'omitnan');
            mean_roi_fc(isinf(mean_roi_fc)) = 0;

            all_subject_fc(subject_idx, :) = mean_roi_fc;
            valid_subject(subject_idx) = true;
        end

        if ~any(valid_subject)
            warning('No valid GSP data found for lesion %s in null %d.', sub_id, null_idx);
            continue;
        end

        [t_values, p_values, q_values, fdr_mask] = ...
            compute_one_sample_ttest_map(all_subject_fc(valid_subject, :), cfg.roi_fdr_alpha);
        out_name = sprintf(cfg.null_tmap_pattern, null_idx, sub_id);
        save(fullfile(out_folder, out_name), ...
            't_values', 'p_values', 'q_values', 'fdr_mask');
    end
end
end
