function compute_real_lesion_tmaps(cfg)
%COMPUTE_REAL_LESION_TMAPS Compute ROI-specific RSFC t-maps for real lesions.
%
% For each lesion ROI, this function extracts ROI-to-whole-brain Fisher-z
% connectivity from each normative GSP participant, performs voxel-wise
% one-sample t-tests across participants, and saves one t-map per lesion.

if ~exist(cfg.output_tmap_dir, 'dir')
    mkdir(cfg.output_tmap_dir);
end

lesion_table = readtable(cfg.lesion_table, 'Range', cfg.lesion_table_range);
valid_contents = load(cfg.valid_indices_mat, cfg.valid_indices_variable);
valid_indices = valid_contents.(cfg.valid_indices_variable);

selected_rows = lesion_table(lesion_table.(cfg.grade_col_name) == cfg.grade_filter, :);

for lesion_idx = 1:height(selected_rows)
    tic;
    subject_id = selected_rows{lesion_idx, cfg.subject_id_col};
    subject_id = normalize_subject_id(subject_id);
    lesion_voxels = selected_rows{lesion_idx, cfg.lesion_index_start_col:end};
    lesion_voxels = normalize_lesion_voxels(lesion_voxels);

    [is_valid, indices_in_valid] = ismember(lesion_voxels, valid_indices);
    roi_rows = indices_in_valid(is_valid);

    if isempty(roi_rows)
        warning('No valid ROI voxels found for lesion %s. Skipping.', subject_id);
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
        roi_fc = rho_z(roi_rows, :);
        mean_roi_fc = mean(roi_fc, 1, 'omitnan');
        mean_roi_fc(isinf(mean_roi_fc)) = 0;
        all_subject_fc(subject_idx, :) = mean_roi_fc;
        valid_subject(subject_idx) = true;
    end

    if ~any(valid_subject)
        warning('No valid GSP data found for lesion %s. Skipping.', subject_id);
        continue;
    end

    [t_values, p_values, q_values, fdr_mask] = ...
        compute_one_sample_ttest_map(all_subject_fc(valid_subject, :), cfg.roi_fdr_alpha);
    output_name = sprintf(cfg.output_tmap_pattern, cfg.grade_filter, subject_id);
    save(fullfile(cfg.output_tmap_dir, output_name), ...
        't_values', 'p_values', 'q_values', 'fdr_mask');

    fprintf('Saved lesion %d/%d: %s (%.1f seconds)\n', ...
        lesion_idx, height(selected_rows), output_name, toc);
end

end

function subject_id = normalize_subject_id(subject_id)
    if iscell(subject_id)
        subject_id = subject_id{1};
    end
    if isnumeric(subject_id)
        subject_id = num2str(subject_id);
    end
    subject_id = char(subject_id);
end

function lesion_voxels = normalize_lesion_voxels(lesion_voxels)
    if iscell(lesion_voxels)
        lesion_voxels = cellfun(@parse_voxel_index, lesion_voxels);
    end
    lesion_voxels = lesion_voxels(:)';
    lesion_voxels = lesion_voxels(~isnan(lesion_voxels));
end

function voxel_index = parse_voxel_index(value)
    if isempty(value)
        voxel_index = NaN;
    elseif isnumeric(value)
        voxel_index = double(value);
    else
        voxel_index = str2double(char(value));
    end
end
