import os
import matplotlib.pyplot as plt
import numpy as np

# Set standard styles for research papers
plt.style.use('seaborn-v0_8-whitegrid' if 'seaborn-v0_8-whitegrid' in plt.style.available else 'default')
plt.rcParams.update({
    'font.family': 'serif',
    'font.serif': ['Times New Roman', 'Times', 'DejaVu Serif'],
    'font.size': 10,
    'axes.labelsize': 10,
    'axes.titlesize': 11,
    'xtick.labelsize': 9,
    'ytick.labelsize': 9,
    'legend.fontsize': 8,
    'figure.titlesize': 12,
    'figure.dpi': 300,
    'savefig.dpi': 300
})

# Create Images directory if it doesn't exist
os.makedirs('Images', exist_ok=True)

# Color Palette (Slate Blue, Olive Green, Coral Red)
colors = {
    'no_pi': '#4e79a7',
    'true_pi': '#59a14f',
    'est_pi': '#e15759'
}

# Data
# 1. Varying Sample Size
N = np.array([100, 500, 1000, 10000])
rmse_cate_no_pi_n = np.array([0.133, 0.096, 0.084, 0.047])
rmse_cate_true_pi_n = np.array([0.129, 0.095, 0.083, 0.046])
rmse_cate_est_pi_n = np.array([0.133, 0.104, 0.094, 0.048])
rmse_ate_no_pi_n = np.array([0.119, 0.072, 0.058, 0.017])
rmse_ate_true_pi_n = np.array([0.115, 0.075, 0.061, 0.017])
rmse_ate_est_pi_n = np.array([0.118, 0.083, 0.070, 0.019])
cover_cate_no_pi_n = np.array([0.999, 0.976, 0.969, 0.968])
cover_cate_true_pi_n = np.array([0.999, 0.972, 0.972, 0.972])
cover_cate_est_pi_n = np.array([1.000, 0.974, 0.950, 0.959])
cover_ate_no_pi_n = np.array([1.000, 0.950, 0.910, 0.960])
cover_ate_true_pi_n = np.array([1.000, 0.960, 0.920, 0.930])
cover_ate_est_pi_n = np.array([1.000, 0.920, 0.850, 0.930])

# 2. Varying Mu Trees
mu_trees = np.array([5, 25, 100, 400])
rmse_cate_no_pi_mu = np.array([0.162, 0.115, 0.114, 0.116])
rmse_cate_true_pi_mu = np.array([0.111, 0.107, 0.110, 0.109])
rmse_cate_est_pi_mu = np.array([0.170, 0.125, 0.124, 0.130])
rmse_ate_no_pi_mu = np.array([0.101, 0.095, 0.091, 0.093])
rmse_ate_true_pi_mu = np.array([0.094, 0.089, 0.091, 0.090])
rmse_ate_est_pi_mu = np.array([0.109, 0.105, 0.106, 0.105])
cover_cate_no_pi_mu = np.array([0.959, 0.977, 0.983, 0.983])
cover_cate_true_pi_mu = np.array([0.980, 0.980, 0.978, 0.985])
cover_cate_est_pi_mu = np.array([0.957, 0.970, 0.976, 0.977])
cover_ate_no_pi_mu = np.array([0.910, 0.940, 0.950, 0.950])
cover_ate_true_pi_mu = np.array([0.950, 0.920, 0.940, 0.950])
cover_ate_est_pi_mu = np.array([0.880, 0.900, 0.920, 0.910])

# 3. Varying Covariates
p_covs = np.array([10, 50, 100, 200])
rmse_cate_no_pi_p = np.array([0.106, 0.117, 0.110, 0.110])
rmse_cate_true_pi_p = np.array([0.103, 0.117, 0.110, 0.111])
rmse_cate_est_pi_p = np.array([0.106, 0.117, 0.109, 0.111])
rmse_ate_no_pi_p = np.array([0.085, 0.101, 0.093, 0.092])
rmse_ate_true_pi_p = np.array([0.084, 0.100, 0.094, 0.093])
rmse_ate_est_pi_p = np.array([0.085, 0.100, 0.092, 0.093])
cover_cate_no_pi_p = np.array([0.989, 0.974, 0.980, 0.983])
cover_cate_true_pi_p = np.array([0.984, 0.970, 0.975, 0.983])
cover_cate_est_pi_p = np.array([0.992, 0.976, 0.984, 0.980])
cover_ate_no_pi_p = np.array([0.990, 0.950, 0.970, 0.950])
cover_ate_true_pi_p = np.array([0.980, 0.950, 0.950, 0.970])
cover_ate_est_pi_p = np.array([0.980, 0.950, 0.980, 0.960])

# Create 3x2 Grid Figure
fig, axes = plt.subplots(3, 2, figsize=(10, 11))

# Row 1: Varying Sample Size
ax1, ax2 = axes[0]
ax1.plot(N, rmse_cate_no_pi_n, color=colors['no_pi'], linestyle='-', marker='o', label=r'BCF (no $\hat{\pi}$) - CATE')
ax1.plot(N, rmse_cate_true_pi_n, color=colors['true_pi'], linestyle='-', marker='s', label=r'BCF ($\pi$) - CATE')
ax1.plot(N, rmse_cate_est_pi_n, color=colors['est_pi'], linestyle='-', marker='^', label=r'BCF ($\hat{\pi}$) - CATE')
ax1.plot(N, rmse_ate_no_pi_n, color=colors['no_pi'], linestyle='--', marker='o', alpha=0.7, label=r'BCF (no $\hat{\pi}$) - ATE')
ax1.plot(N, rmse_ate_true_pi_n, color=colors['true_pi'], linestyle='--', marker='s', alpha=0.7, label=r'BCF ($\pi$) - ATE')
ax1.plot(N, rmse_ate_est_pi_n, color=colors['est_pi'], linestyle='--', marker='^', alpha=0.7, label=r'BCF ($\hat{\pi}$) - ATE')
ax1.set_xscale('log')
ax1.set_xlabel('Sample Size ($N$)')
ax1.set_ylabel('RMSE')
ax1.set_title('A: Estimation Error (RMSE) across Sample Sizes')
ax1.set_xticks(N)
ax1.set_xticklabels([str(n) for n in N])
ax1.legend(ncol=2, frameon=True, loc='upper right')

ax2.plot(N, cover_cate_no_pi_n, color=colors['no_pi'], linestyle='-', marker='o')
ax2.plot(N, cover_cate_true_pi_n, color=colors['true_pi'], linestyle='-', marker='s')
ax2.plot(N, cover_cate_est_pi_n, color=colors['est_pi'], linestyle='-', marker='^')
ax2.plot(N, cover_ate_no_pi_n, color=colors['no_pi'], linestyle='--', marker='o', alpha=0.7)
ax2.plot(N, cover_ate_true_pi_n, color=colors['true_pi'], linestyle='--', marker='s', alpha=0.7)
ax2.plot(N, cover_ate_est_pi_n, color=colors['est_pi'], linestyle='--', marker='^', alpha=0.7)
ax2.axhline(0.95, color='gray', linestyle=':', label='Nominal 95% Cover')
ax2.set_xscale('log')
ax2.set_xlabel('Sample Size ($N$)')
ax2.set_ylabel('Interval Coverage')
ax2.set_title('B: 95% Credible Interval Coverage across Sample Sizes')
ax2.set_xticks(N)
ax2.set_xticklabels([str(n) for n in N])
ax2.legend(frameon=True, loc='lower left')

# Row 2: Varying Mu Trees
ax3, ax4 = axes[1]
ax3.plot(mu_trees, rmse_cate_no_pi_mu, color=colors['no_pi'], linestyle='-', marker='o')
ax3.plot(mu_trees, rmse_cate_true_pi_mu, color=colors['true_pi'], linestyle='-', marker='s')
ax3.plot(mu_trees, rmse_cate_est_pi_mu, color=colors['est_pi'], linestyle='-', marker='^')
ax3.plot(mu_trees, rmse_ate_no_pi_mu, color=colors['no_pi'], linestyle='--', marker='o', alpha=0.7)
ax3.plot(mu_trees, rmse_ate_true_pi_mu, color=colors['true_pi'], linestyle='--', marker='s', alpha=0.7)
ax3.plot(mu_trees, rmse_ate_est_pi_mu, color=colors['est_pi'], linestyle='--', marker='^', alpha=0.7)
ax3.set_xscale('log')
ax3.set_xlabel('Number of $\mu$ Trees')
ax3.set_ylabel('RMSE')
ax3.set_title('C: Estimation Error (RMSE) across $\mu$ Trees')
ax3.set_xticks(mu_trees)
ax3.set_xticklabels([str(t) for t in mu_trees])

ax4.plot(mu_trees, cover_cate_no_pi_mu, color=colors['no_pi'], linestyle='-', marker='o')
ax4.plot(mu_trees, cover_cate_true_pi_mu, color=colors['true_pi'], linestyle='-', marker='s')
ax4.plot(mu_trees, cover_cate_est_pi_mu, color=colors['est_pi'], linestyle='-', marker='^')
ax4.plot(mu_trees, cover_ate_no_pi_mu, color=colors['no_pi'], linestyle='--', marker='o', alpha=0.7)
ax4.plot(mu_trees, cover_ate_true_pi_mu, color=colors['true_pi'], linestyle='--', marker='s', alpha=0.7)
ax4.plot(mu_trees, cover_ate_est_pi_mu, color=colors['est_pi'], linestyle='--', marker='^', alpha=0.7)
ax4.axhline(0.95, color='gray', linestyle=':')
ax4.set_xscale('log')
ax4.set_xlabel('Number of $\mu$ Trees')
ax4.set_ylabel('Interval Coverage')
ax4.set_title('D: 95% Credible Interval Coverage across $\mu$ Trees')
ax4.set_xticks(mu_trees)
ax4.set_xticklabels([str(t) for t in mu_trees])

# Row 3: Varying Covariates
ax5, ax6 = axes[2]
ax5.plot(p_covs, rmse_cate_no_pi_p, color=colors['no_pi'], linestyle='-', marker='o')
ax5.plot(p_covs, rmse_cate_true_pi_p, color=colors['true_pi'], linestyle='-', marker='s')
ax5.plot(p_covs, rmse_cate_est_pi_p, color=colors['est_pi'], linestyle='-', marker='^')
ax5.plot(p_covs, rmse_ate_no_pi_p, color=colors['no_pi'], linestyle='--', marker='o', alpha=0.7)
ax5.plot(p_covs, rmse_ate_true_pi_p, color=colors['true_pi'], linestyle='--', marker='s', alpha=0.7)
ax5.plot(p_covs, rmse_ate_est_pi_p, color=colors['est_pi'], linestyle='--', marker='^', alpha=0.7)
ax5.set_xlabel('Number of Covariates ($p$)')
ax5.set_ylabel('RMSE')
ax5.set_title('E: Estimation Error (RMSE) across Covariates')
ax5.set_xticks(p_covs)

ax6.plot(p_covs, cover_cate_no_pi_p, color=colors['no_pi'], linestyle='-', marker='o')
ax6.plot(p_covs, cover_cate_true_pi_p, color=colors['true_pi'], linestyle='-', marker='s')
ax6.plot(p_covs, cover_cate_est_pi_p, color=colors['est_pi'], linestyle='-', marker='^')
ax6.plot(p_covs, cover_ate_no_pi_p, color=colors['no_pi'], linestyle='--', marker='o', alpha=0.7)
ax6.plot(p_covs, cover_ate_true_pi_p, color=colors['true_pi'], linestyle='--', marker='s', alpha=0.7)
ax6.plot(p_covs, cover_ate_est_pi_p, color=colors['est_pi'], linestyle='--', marker='^', alpha=0.7)
ax6.axhline(0.95, color='gray', linestyle=':')
ax6.set_xlabel('Number of Covariates ($p$)')
ax6.set_ylabel('Interval Coverage')
ax6.set_title('F: 95% Credible Interval Coverage across Covariates')
ax6.set_xticks(p_covs)

plt.tight_layout()
plt.savefig('Images/conditional_ablation_grid.png')
plt.close()

print("Unified 3x2 ablation grid plot generated successfully.")
