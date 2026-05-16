# Glioma Network Mapping

Code accompanying a glioma network mapping analysis based on normative
resting-state functional connectivity.

This repository is being organized into two parts:

1. Real-lesion network mapping from true glioma lesion ROIs.
2. Size-matched null model testing for statistical validation.

The cleaned implementation uses the same ROI-specific t-map, FDR correction
at `q < 0.01`, and `|t| > 5` overlap procedure for both real lesions and
synthetic null lesions.

## Repository Layout

```text
config/       Example configuration files with local paths and parameters.
src/matlab/   Reusable MATLAB functions.
scripts/      Entry-point scripts for running each analysis step.
docs/         Method notes and input/output descriptions.
legacy/       Original scripts preserved for traceability.
```

## Real-Lesion Pipeline

Copy `config/real_lesion_config.example.m` to
`config/real_lesion_config.m`, update the paths, and run:

```matlab
run('scripts/run_01_compute_real_lesion_tmaps.m')
run('scripts/run_02_generate_observed_network.m')
```

The first script generates one ROI-specific t-map for each true lesion. The
second script thresholds these t-maps at `|t| > 5` and computes the observed
glioma network overlap map.

More details are provided in `docs/real_lesion_pipeline.md`.

Input requirements are summarized in `docs/expected_inputs.md`.

## Null Model Pipeline

Copy `config/null_model_config.example.m` to
`config/null_model_config.m`, update the paths, and run:

```matlab
run('scripts/run_03_estimate_size_matched_cube_dims.m')
run('scripts/run_04_generate_synthetic_lesions.m')
run('scripts/run_05_compute_null_lesion_tmaps.m')
run('scripts/run_06_generate_null_network_maps.m')
run('scripts/run_07_voxelwise_null_ratio_test.m')
run('scripts/run_08_apply_ratio_fdr.m')
```

More details are provided in `docs/null_model_pipeline.md`.
