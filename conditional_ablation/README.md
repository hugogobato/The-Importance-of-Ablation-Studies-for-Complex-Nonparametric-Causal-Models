# Conditional Ablation Studies

These three studies vary **one dimension at a time** for DGP1 extreme, alpha=4 (the hardest RIC setting). Paper Figure `conditional_ablation_grid.png` (6 panels) summarizes them.

## 1. Varying sample size (`varying_sample_size/`)

- **N ∈ {100, 500, 1000, 10000}**
- DGP1 extreme, alpha=4, p=5, 100 replications
- Notebooks: `BCF(no_pi_hat)_part_1.ipynb` (N=100,500), `BCF(no_pi_hat)_part_2.ipynb` (N=1000,10000), similarly for `pi_hat` and `pi_oracle` (split into `part_1` / `part_2_1000` / `part_2_10000` because N=10k takes ~8–10h per variant).
- Results: `BCF*_N*.xlsx` (12 files, 3 variants × 4 N) + `Results_Summary.R` + `details.txt` (timings: pi_hat N=10k ≈10h20m, no_pi_hat ≈8h45m).
- R templates: `../scripts/BCF_sample_size_template.R`

## 2. Varying prognostic forest capacity (`varying_mu_trees/`)

- **mu trees ∈ {5, 25, 100, 400}** (prognostic forest; tau forest fixed 50 trees, eta=0.25, beta=3)
- DGP1 extreme, alpha=4, N=250, 100 reps
- Single notebook `BCF (all).ipynb` loops over the four tree settings and all three variants (pi_hat, no_pi_hat, oracle). Also split per-variant in original `Exp` shards (now consolidated).
- Results: `BCF*_mu_trees_*.xlsx` (12 files) + `details.txt` (mu=400 with pi_hat ≈1h20m).
- R script: `BCF_mu_trees.R` (extracted from notebook)

## 3. Varying covariate dimension (`varying_covariates/`)

- **p ∈ {10, 50, 100, 200}** (generalized DGP: baseline summed over p/5 blocks of 5 covariates, p must be multiple of 5)
- DGP1 extreme, alpha=4, N=250, 100 reps
- Notebooks: `BCF(no_pi_hat)_part_1_cov.ipynb` (p=10), `part_2_cov` (p=50), `part_3` (p=100,200) — same split for pi_hat and pi_oracle. `BCF(pi_hat)_part_1_cov_p5.ipynb` is the p=5 test shard (2 reps) corresponding to `BCF(pi_hat)_num_covariates_5.xlsx`.
- Results: `BCF*_num_covariates_*.xlsx` (13 files incl. p=5) + `details.txt` (p=200 with pi_hat ≈11h30m).
- R template: `BCF_covariates_template.R` + `Dataset.ipynb` (shows block-sum logic)

**All three ablations show null effect of pi_hat** (Welch p ≫0.05, coverage conservative but identical). See paper §5 and `images/conditional_ablation_*.png`.

To reproduce any panel: adjust `num_covariates_list`, `n_tree_mu_list`, or `N` in the corresponding notebook/R script and source it.
