function apply_ratio_fdr(cfg)
%APPLY_RATIO_FDR Convert ratio to p-values and apply BH-FDR correction.

ratio_data = load(cfg.output_ratio_mat, 'ratio');
ratio = ratio_data.ratio;

pval = 1 - ratio;
pval(pval < eps) = eps;
pval(pval > 1) = 1;

pval_vec = pval(:);
qval_vec = bh_fdr(pval_vec);
qval = reshape(qval_vec, size(pval));
significant_mask = qval < cfg.fdr_alpha;

output_dir = fileparts(cfg.output_fdr_mat);
if ~isempty(output_dir) && ~exist(output_dir, 'dir')
    mkdir(output_dir);
end

save(cfg.output_fdr_mat, 'ratio', 'pval', 'qval', 'significant_mask', '-v7.3');
fprintf('Number of voxels with q < %.5g: %d\n', cfg.fdr_alpha, sum(significant_mask(:)));
fprintf('Saved FDR results to: %s\n', cfg.output_fdr_mat);
end

function qvals = bh_fdr(pvals)
    pvals = pvals(:);
    n = numel(pvals);
    [sorted_p, sort_idx] = sort(pvals);
    sorted_q = sorted_p .* n ./ (1:n)';

    for idx = n-1:-1:1
        sorted_q(idx) = min(sorted_q(idx), sorted_q(idx + 1));
    end

    sorted_q(sorted_q > 1) = 1;
    qvals = zeros(size(pvals));
    qvals(sort_idx) = sorted_q;
end
