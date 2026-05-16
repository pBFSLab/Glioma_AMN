# Real-Lesion Network Mapping Pipeline

## Step 1: ROI-specific t-maps

`compute_real_lesion_tmaps` reads a lesion table, treats each lesion as an
ROI, extracts ROI-to-whole-brain Fisher-z connectivity from each normative
GSP participant, and performs voxel-wise one-sample t-tests across
participants. Benjamini-Hochberg FDR correction is then applied across
voxels for each ROI-specific t-map using `cfg.roi_fdr_alpha = 0.01`.

Output: one file per lesion containing `t_values`, `p_values`, `q_values`,
and `fdr_mask`.

## Step 2: Observed glioma network map

`generate_observed_lesion_network` thresholds each lesion t-map at
`q < 0.01` and `|t| > 5`, then counts the dominant positive or negative RSFC
pattern at each voxel.
The final `overlap` vector is `count / number_of_lesions`.

Positive values indicate overlap of positive RSFC. Negative values indicate
overlap of anti-correlated RSFC.`
