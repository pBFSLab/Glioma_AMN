function estimate_size_matched_cube_dims(cfg)
%ESTIMATE_SIZE_MATCHED_CUBE_DIMS Approximate each lesion volume by a cuboid.

opts = detectImportOptions(cfg.lesion_table);
opts.DataRange = cfg.lesion_table_data_range;
opts = setvartype(opts, cfg.subject_id_col, 'char');
tbl = readtable(cfg.lesion_table, opts);

patient_id = tbl{:, cfg.subject_id_col};
volumes = tbl{:, cfg.lesion_volume_col};
n_lesion = numel(volumes);

dims = zeros(n_lesion, 3);
fake_vol = zeros(n_lesion, 1);

for lesion_idx = 1:n_lesion
    volume = volumes(lesion_idx);
    [dims(lesion_idx, :), fake_vol(lesion_idx)] = ...
        find_compact_cuboid(volume, cfg.volume_tolerance, cfg.search_half_range);

    fprintf('Lesion %d | ID=%s | TrueVol=%d | Cube=%dx%dx%d | FakeVol=%d\n', ...
        lesion_idx, char(patient_id(lesion_idx)), volume, dims(lesion_idx, 1), ...
        dims(lesion_idx, 2), dims(lesion_idx, 3), fake_vol(lesion_idx));
end

out_tbl = table(patient_id, volumes, dims(:, 1), dims(:, 2), dims(:, 3), fake_vol, ...
    'VariableNames', {'PatientID', 'TrueVolume', 'DimX', 'DimY', 'DimZ', 'FakeVolume'});

output_dir = fileparts(cfg.cube_dims_xlsx);
if ~isempty(output_dir) && ~exist(output_dir, 'dir')
    mkdir(output_dir);
end
writetable(out_tbl, cfg.cube_dims_xlsx);
end

function [best_dims, best_volume] = find_compact_cuboid(volume, tolerance, search_half_range)
    best_var = inf;
    best_dims = [1, 1, volume];

    root_volume = round(volume^(1/3));
    search_range = max(1, root_volume - search_half_range):(root_volume + search_half_range);

    for dim_x = search_range
        for dim_y = search_range
            dim_z = round(volume / (dim_x * dim_y));
            if dim_z < 1
                continue;
            end

            candidate_volume = dim_x * dim_y * dim_z;
            if abs(candidate_volume - volume) <= tolerance
                candidate_var = var([dim_x, dim_y, dim_z]);
                if candidate_var < best_var
                    best_var = candidate_var;
                    best_dims = [dim_x, dim_y, dim_z];
                end
            end
        end
    end

    if isinf(best_var)
        best_dims = [root_volume, root_volume, max(1, round(volume / root_volume^2))];
    end

    best_volume = prod(best_dims);
end
