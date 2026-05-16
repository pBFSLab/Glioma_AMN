# Expected Inputs

## Lesion Table

The lesion table is an Excel file with one row per lesion.

Required fields:

* A subject or lesion identifier column, configured by `cfg.subject_id_col`.

* A grade column named by `cfg.grade_col_name`.

* Lesion voxel indices from `cfg.lesion_index_start_col` to the final column.

Voxel indices should use the same indexing space as `valid_indices`.

## Valid Indices&#x20;

### --> To reduce computational complexity, mask out non-brain tissue

`cfg.valid_indices_mat` must contain a vector named by `cfg.valid_indices_variable`. This vector maps lesion voxel indices to rows and columns in the GSP `rho_z` matrices.

## GSP rho-z Matrices

Each GSP participant should have a `.mat` file at:

```text
cfg.gsp_rhoz_dir / sprintf(cfg.gsp_subject_pattern, subject_id) / cfg.rhoz_filename
```

The file must contain a matrix named by `cfg.rhoz_variable`. Rows correspond to ROI seed voxels and columns correspond to whole-brain voxels.

## Outputs

Step 1 saves `t_values`, `p_values`, `q_values`, and `fdr_mask` for each lesion in `cfg.output_tmap_dir`.

Step 2 saves:

* `overlap`: signed observed glioma network overlap.

* `count`: signed dominant positive/negative count.

* `positive_count`: number of lesions with `t > cfg.t_threshold`.

* `negative_count`: number of lesions with `t < -cfg.t_threshold`.

* `num_lesions`: number of lesion t-maps included.

## Null Model Inputs

The null model additionally requires:

* A lesion table with real lesion volumes.

* A brain mask NIfTI file used for random synthetic lesion placement.

* Individual GSP `rho_z.mat` files, using the same format as the real-lesion t-map step.

