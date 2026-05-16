# Size-Matched Null Model Pipeline

This pipeline tests whether the observed glioma network is stronger than
expected from size-matched synthetic lesions.

The implementation uses the same `t_values` and `|t| > 5` overlap procedure for synthetic lesions as for real lesions.

## Step 1: Estimate Synthetic Lesion Dimensions

`estimate_size_matched_cube_dims` approximates each real lesion volume with a
compact cuboid. The output table stores `DimX`, `DimY`, `DimZ`, and the
approximated synthetic lesion volume.

Entry point:

```matlab
run('scripts/run_03_estimate_size_matched_cube_dims.m')
```

## Step 2: Generate Synthetic Lesions

`generate_size_matched_synthetic_lesions` randomly positions the cuboids
inside the brain mask. Each null iteration contains one synthetic lesion for
each real lesion.

Entry point:

```matlab
run('scripts/run_04_generate_synthetic_lesions.m')
```

## Step 3: Compute Synthetic Lesion t-maps

`compute_null_lesion_tmaps` mirrors the real-lesion t-map step. For each
synthetic lesion, it extracts ROI-to-whole-brain Fisher-z connectivity from
each GSP participant and performs voxel-wise one-sample t-tests across
participants. Benjamini-Hochberg FDR correction is applied across voxels for
each synthetic lesion t-map.

Entry point:

```matlab
run('scripts/run_05_compute_null_lesion_tmaps.m')
```

## Step 4: Generate Null Network Maps

`generate_null_network_maps` thresholds each synthetic lesion t-map at
`q < 0.01` and `|t| > 5`, counts positive and negative RSFC overlap, and
saves one signed overlap map for each null iteration.

Entry point:

```matlab
run('scripts/run_06_generate_null_network_maps.m')
```

## Step 5: Voxel-Wise Null Test

`voxelwise_null_ratio_test` compares the observed real-lesion overlap map
with all null overlap maps at each voxel. Positive voxels are tested against
greater null overlap values; negative voxels are tested against more negative
null overlap values.

Entry point:

```matlab
run('scripts/run_07_voxelwise_null_ratio_test.m')
```

## Step 6: FDR Correction

`apply_ratio_fdr` converts the voxel-wise ratio to `p = 1 - ratio`, applies
Benjamini-Hochberg FDR correction, and saves `pval`, `qval`, and
`significant_mask`.

Entry point:

```matlab
run('scripts/run_08_apply_ratio_fdr.m')
```

