function generate_size_matched_synthetic_lesions(cfg)
%GENERATE_SIZE_MATCHED_SYNTHETIC_LESIONS Randomly place size-matched lesions.
%
% Requires FreeSurfer's MRIread on the MATLAB path for NIfTI input.

rng(cfg.rng_seed);
if ~exist(cfg.synthetic_lesion_dir, 'dir')
    mkdir(cfg.synthetic_lesion_dir);
end

tbl = readtable(cfg.cube_dims_xlsx);
subject_ids = tbl{:, 1};
dim_x = tbl{:, 3};
dim_y = tbl{:, 4};
dim_z = tbl{:, 5};
num_indices = tbl{:, 6};
n_lesion = height(tbl);

mri = MRIread(cfg.brain_mask_nii);
brain_mask = mri.vol ~= 0;
brain_dim = size(brain_mask);
valid_center_lin = find(brain_mask);

for null_idx = 1:cfg.num_null
    fprintf('\n=== Generating null %05d / %05d ===\n', null_idx, cfg.num_null);
    null_data = struct();

    if cfg.save_synthetic_xlsx
        out_xlsx = fullfile(cfg.synthetic_lesion_dir, sprintf('null_%05d.xlsx', null_idx));
        header = cell(1, 3 + max(num_indices));
        header(1:4) = {'Subid', 'Grade', 'NumInd', 'Ind'};
        writecell(header, out_xlsx);
    end

    for lesion_idx = 1:n_lesion
        dims = [dim_x(lesion_idx), dim_y(lesion_idx), dim_z(lesion_idx)];
        dims = dims(randperm(3));
        lin_idx = place_cuboid_in_mask(brain_mask, brain_dim, valid_center_lin, dims);

        null_data(lesion_idx).Subid = normalize_id(subject_ids(lesion_idx));
        null_data(lesion_idx).NumInd = num_indices(lesion_idx);
        null_data(lesion_idx).lin_idx = lin_idx;

        if cfg.save_synthetic_xlsx
            row = cell(1, 3 + numel(lin_idx));
            row{1} = null_data(lesion_idx).Subid;
            row{2} = cfg.synthetic_grade;
            row{3} = num_indices(lesion_idx);
            row(4:end) = num2cell(lin_idx);
            writecell(row, out_xlsx, 'WriteMode', 'append');
        end
    end

    out_mat = fullfile(cfg.synthetic_lesion_dir, sprintf('null_%05d.mat', null_idx));
    save(out_mat, 'null_data', '-v7.3');
end
end

function lin_idx = place_cuboid_in_mask(brain_mask, brain_dim, valid_center_lin, dims)
    dim_x = dims(1);
    dim_y = dims(2);
    dim_z = dims(3);
    half_x = floor(dim_x / 2);
    half_y = floor(dim_y / 2);
    half_z = floor(dim_z / 2);

    while true
        center_lin = valid_center_lin(randi(numel(valid_center_lin)));
        [center_x, center_y, center_z] = ind2sub(brain_dim, center_lin);

        x_range = (center_x - half_x):(center_x + dim_x - half_x - 1);
        y_range = (center_y - half_y):(center_y + dim_y - half_y - 1);
        z_range = (center_z - half_z):(center_z + dim_z - half_z - 1);

        if min(x_range) < 1 || max(x_range) > brain_dim(1) || ...
           min(y_range) < 1 || max(y_range) > brain_dim(2) || ...
           min(z_range) < 1 || max(z_range) > brain_dim(3)
            continue;
        end

        mask_block = brain_mask(x_range, y_range, z_range);
        if ~all(mask_block(:))
            continue;
        end

        [grid_x, grid_y, grid_z] = ndgrid(x_range, y_range, z_range);
        lin_idx = sub2ind(brain_dim, grid_x(:), grid_y(:), grid_z(:));
        return;
    end
end

function id = normalize_id(value)
    if iscell(value)
        value = value{1};
    end
    if isnumeric(value)
        id = num2str(value);
    else
        id = char(value);
    end
end
