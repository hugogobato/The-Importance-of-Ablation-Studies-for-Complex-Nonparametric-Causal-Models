# Images

Paper-ready figures copied from `Paper/Images/`:

- `Extreme.png`, `Moderate.png`, `Slight.png` — scatter pi vs b for DGP1-3
- `conditional_ablation_grid.png` — main Figure 3 (6 panels: RMSE/Cover × N/mu/p)
- `t_test_results_p_value_*.png` — Welch p-values for main and conditional studies
- `BCF_covariates_*.png`, `conditional_ablation_*.png` — per-dimension views
- `Propensity_Scores.png` — supplemental

Regenerate the conditional grid via `python ../generate_plots.py` (uses hard-coded paper means from `Paper/generate_plots.py`) or via R `Results_Summary.R` per folder.
