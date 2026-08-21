# The Importance of Ablation Studies for Complex Nonparametric Causal Models

[![R](https://img.shields.io/badge/R-4.3%2B-blue)](https://cran.r-project.org/)
[![Python](https://img.shields.io/badge/Python-3.9%2B-green)](https://www.python.org/)
[![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg)](https://opensource.org/licenses/MIT)

**Authors:** Hugo Gobato Souto, Francisco Louzada (ICMC-USP)  
**Paper:** *The Importance of Ablation Studies for Complex Nonparametric Causal Models* — accepted for publication (WICS 2020 / SBC).  
**Contact:** hugogobatosouto@gmail.com, louzada@icmc.usp.br

This repository contains the **clean, reproducible code and results** for the ablation study on the **Bayesian Causal Forest (BCF)** model [Hahn et al., 2020]. We show that the estimated propensity score \(\hat{\pi}(x)\) — introduced to mitigate Regularization-Induced Confounding (RIC) — is **not required** for accurate ATE/CATE estimation or coverage, and that omitting it **saves ~21% compute**.

> **For readers of the paper:** run one command to regenerate the synthetic data and reproduce all tables/figures — see *Quick Start* below. Raw `dataset_*.csv` files are no longer stored; an `example_dataset.csv` per DGP is included for inspection.

---

## 1. Repository Structure

```
.
├── README.md
├── LICENSE
├── requirements.txt          # Python dependencies
├── install_R.R               # R dependencies (stochtree, dbarts, openxlsx, etc.)
├── generate_plots.py         # Reproduces paper Figures (conditional ablation grid, t-test p-values)
├── data_generation/
│   ├── Creating_datasets.py         # ★ Unified generator: --dgp {extreme,moderate,slight,all} --alpha {1,2,4} --n 250
│   └── legacy/                      # Original per-DGP scripts for provenance
├── main_ablation/
│   ├── scripts/
│   │   ├── BCF_N250.R               # BCF with estimated pi_hat (bart)
│   │   ├── BCF (no_pi_hat)_N250.R   # BCF without pi_hat (pi=0.5)
│   │   ├── BCF(pi_oracle)_N250.R    # BCF with true pi (oracle)
│   │   ├── Results_Summary.R        # Aggregates xlsx → mean±sd, boxplots
│   │   └── Statistical_tests.R      # Welch t-test, coverage tests
│   ├── DGP1_extreme/                # DGP1: extreme target selection  pi=0.05+0.9*BetaCDF(sigmoid(b))
│   │   ├── alpha_1/                 # alpha=1 (original N=100,250,500)
│   │   ├── alpha_2/                 # alpha=2 (N=250)
│   │   └── alpha_4/                 # alpha=4 (paper Table 1, N=250) ★
│   ├── DGP2_moderate/               # DGP2: moderate  pi=0.05+0.75*BetaCDF(sigmoid(b))+0.15*BetaCDF(min(X1,X2))
│   └── DGP3_slight/                 # DGP3: slight    pi=0.05+0.9*BetaCDF(min(X1,X2))
├── conditional_ablation/
│   ├── varying_sample_size/         # N ∈ {100,500,1000,10000}  (DGP1, alpha=4)
│   ├── varying_mu_trees/            # mu trees ∈ {5,25,100,400}
│   ├── varying_covariates/          # p ∈ {10,50,100,200} (generalized DGP, blocks of 5)
│   └── scripts/
│       ├── BCF_mu_trees.R
│       ├── BCF_covariates_template.R
│       └── BCF_sample_size_template.R
├── images/                          # Paper figures (Extreme.png, Moderate.png, Slight.png, etc.)
└── results/
    └── figures/                     # Generated plots (created by generate_plots.py / R scripts)
```

---

## 2. Quick Start (Reproduce Paper)

### Python environment

```bash
python -m venv venv && source venv/bin/activate
pip install -r requirements.txt
```

### R environment

```r
Rscript install_R.R
# installs stochtree, dbarts, openxlsx, readxl, ggplot2, dplyr, etc.
```

### 2a. Regenerate synthetic data (example: paper Table 1, DGP1 extreme, alpha=4, N=250)

```bash
python data_generation/Creating_datasets.py --dgp extreme --alpha 4 --n 250 --num-simulations 100 --out-dir ./main_ablation/DGP1_extreme/alpha_4/datasets
# For all three DGPs at once:
python data_generation/Creating_datasets.py --dgp all --alpha 4 --n 250 --num-simulations 100
# Alpha variations (paper says results identical):
python data_generation/Creating_datasets.py --dgp extreme --alpha 1 --n 250
python data_generation/Creating_datasets.py --dgp extreme --alpha 2 --n 250
```

Columns per `dataset_i_N250.csv`: `y, X1–X5, w, tau, b, e, ate` (see `DATASETS_NOTE.md` in each alpha folder).

### 2b. Run BCF ablation (requires R)

Each `main_ablation/DGP*/alpha_*/` contains three variants:
- `BCF_N250.R` — original BCF with \(\hat{\pi}(X)\) via `dbarts::bart`
- `BCF (no_pi_hat)_N250.R` — ablation: `pi_train = rep(0.5, n)`
- `BCF(pi_oracle)_N250.R` — oracle with true `e`

```r
# From R, e.g. DGP1 extreme alpha=4:
setwd("main_ablation/DGP1_extreme/alpha_4")
source("../../scripts/BCF_N250.R")               # or BCF (no_pi_hat)_N250.R
# Produces: BCF_N250.xlsx, BCF_CATE_values_N250.xlsx, logs, etc.
```

All three produce `*.xlsx` with per-replication: `CATE_RMSE, CATE_cover, ATE_RMSE, ATE_cover, pi_RMSE, ...`.

### 2c. Summarize & test

```r
setwd("main_ablation/DGP1_extreme/alpha_4")
source("../../scripts/Results_Summary.R")      # prints mean±sd, writes Results.txt, Boxplots_*.png
source("../../scripts/Statistical_tests.R")    # Welch t-test BCF vs no-pi_hat, writes N250_Statistical_Tests.txt
```

Results should match `Results.txt` already committed (e.g., Table 1: BCF no-pi_hat CATE_RMSE 0.157±0.119 vs BCF pi_hat 0.155±0.106, p > 0.5).

### 2d. Conditional ablation

```r
# Varying N (100 to 10000):
setwd("conditional_ablation/varying_sample_size")
# Run notebooks in order: BCF(no_pi_hat)_part_1.ipynb, BCF(no_pi_hat)_part_2.ipynb, ...
# Or source the template R scripts in conditional_ablation/scripts/

# Varying mu trees (5–400):
setwd("conditional_ablation/varying_mu_trees")
# Source BCF (all).ipynb converted to R: ../scripts/BCF_mu_trees.R

# Varying p (10–200):
setwd("conditional_ablation/varying_covariates")
# Source ../scripts/BCF_covariates_template.R  (generalized DGP, p must be multiple of 5)
```

See `details.txt` in each conditional folder for expected runtimes (e.g., p=200 with pi_hat ≈11.5 h).

### 2e. Reproduce figures

```bash
python generate_plots.py
# Writes to results/figures/ and images/conditional_ablation_grid.png etc.
# Or knit the R markdown; images/ already contains paper-ready PNGs.
```

---

## 3. Data Generating Processes (DGPs)

Following Ballinari et al. (2024) and Hahn et al. (2020), with \(\alpha\) controlling baseline dominance:

```
X ~ Uniform(0,1)^5,  D|X ~ Bernoulli(pi(X)),  epsilon ~ N(0,1)
Y = b(X) + (D-0.5) * (X1+X2)/(2*alpha) + epsilon
b(X) = sin(pi*X1*X2) + 2*(X3-0.5)^2 + X4 + 0.5*X5   (slight) 
       or sin(pi*X3) + ... + min(X1,X2) ...       (extreme/moderate, paper Eq.)
alpha ∈ {1,2,4}  → baseline ≈ 3×, 7×, 13× the treatment effect
pi_extreme(X)  = 0.05 + 0.9 * BetaCDF_{2,4}(sigmoid(b(X)))                         (DGP1)
pi_moderate(X) = 0.05 + 0.75*BetaCDF(sigmoid(b(X))) + 0.15*BetaCDF(min(X1,X2))    (DGP2)
pi_slight(X)   = 0.05 + 0.9 * BetaCDF(min(X1,X2))                                  (DGP3)
```

`alpha=4` is the paper’s main stress test (Table 1, Figure conditional_ablation_grid). `alpha=1,2` give identical conclusions and are provided under each `alpha_*` folder.

**Conditional ablation** (DGP1, alpha=4 only):
- **Sample size:** N ∈ {100,500,1000,10000}
- **Mu trees:** 5, 25, 100, 400 (prognostic forest; tau forest fixed at 50 trees, eta=0.25, beta=3)
- **Covariates:** p ∈ {10,50,100,200} via block-summing of 5-covariate baseline (p multiple of 5)

---

## 4. Results Summary

- **Main ablation (N=250, alpha=4, 100 reps):** all three BCF variants (no pi_hat, oracle, pi_hat) are statistically identical on `RMSE_CATE`, `Cover_CATE`, `RMSE_ATE`, `Cover_ATE` (Welch p ≫ 0.05) across DGP1–DGP3. BCF without pi_hat is ~21% faster.
- **Conditional:** same null result holds across N, mu trees, and p — including high-dimensional (p=200) and tiny-n (N=100) regimes where RIC would be maximal.
- Precomputed `Results.txt`, `*_Statistical_Tests.txt`, `*.xlsx`, and `Boxplots_*.png` in each folder match the paper.

---

## 5. Requirements

**Python:** `numpy`, `scipy`, `pandas` (see `requirements.txt`)  
**R:** `stochtree`, `dbarts`, `openxlsx`/`readxl`, `ggplot2`, `reshape2`, `dplyr`, `progress` (see `install_R.R`; `bcf` is from `stochtree`)  
**Hardware:** Table 1 (N=250) ≈21 min (no pi_hat) / 26 min (with pi_hat) per 100 reps. Full conditional grid (N=10k, p=200) is heavy — use `details.txt` timings and consider sharding across machines (original runs used parallel VS Code windows; now scripts support single-machine `--num-simulations` or manual shard).

---

## 6. Citation

```bibtex
@inproceedings{souto2024ablationbcf,
  title={The Importance of Ablation Studies for Complex Nonparametric Causal Models},
  author={Souto, Hugo Gobato and Louzada, Francisco},
  booktitle={Workshop on Information and Communication Systems (WICS) / SBC},
  year={2024}
}
```

If you use the BCF implementation, please also cite:

```bibtex
@article{hahn2020bayesian,
  title={Bayesian regression tree models for causal inference},
  author={Hahn, P. Richard and Murray, Jared S. and Carvalho, Carlos M.},
  journal={Bayesian Analysis},
  year={2020}
}
```

---

## 7. License & Reproducibility

- Code released under **MIT** (see `LICENSE`).
- Paper text and figures under **CC BY 4.0** (per WICS authorization).
- All random seeds explicit in `Creating_datasets.py` (`np.random.seed` per simulation index + `R set.seed` in R scripts). To reproduce exact paper numbers, run with the same `sigma=1.0` and default `beta(2,4)` as in the committed scripts.
- For large experiments (N=10k, p=200), use `data_generation/Creating_datasets.py --out-dir /tmp/...` to avoid bloating the repo; results `*.xlsx` already committed cover the paper’s claims.

---

## 8. Changelog

- **2024-10-24**: Initial experiments (`Experiments/Used/` with `Exp` parallel shards).
- **2026-08-20**: Clean release v1.0 — removed `Zone.Identifier`, deduplicated 5.7 k duplicate datasets/Exp folders, renamed to `DGP*/alpha_*`, unified `Creating_datasets.py`, added `install_R.R`, `requirements.txt`, and this README.

*Questions? Open an issue or email hugogobatosouto@gmail.com.*
