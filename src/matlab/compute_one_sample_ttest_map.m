function [t_values, p_values, q_values, fdr_mask] = compute_one_sample_ttest_map(all_subject_fc, fdr_alpha)
%COMPUTE_ONE_SAMPLE_TTEST_MAP Voxel-wise one-sample t-tests and BH-FDR.

n = size(all_subject_fc, 1);
mu = mean(all_subject_fc, 1, 'omitnan');
sigma = std(all_subject_fc, 0, 1, 'omitnan');

t_values = mu ./ (sigma ./ sqrt(n));
t_values(isnan(t_values) | isinf(t_values)) = 0;

p_values = 2 * tcdf(-abs(t_values), n - 1);
p_values(isnan(p_values) | isinf(p_values)) = 1;
p_values(p_values < eps) = eps;
p_values(p_values > 1) = 1;

q_values = bh_fdr(p_values(:));
q_values = reshape(q_values, size(p_values));
fdr_mask = q_values < fdr_alpha;
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
