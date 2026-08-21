# Data Generation

## Quick use

```bash
pip install -r ../requirements.txt
python Creating_datasets.py --dgp all --alpha 4 --n 250 --num-simulations 100
python Creating_datasets.py --dgp extreme --alpha 4 --n 500 --num-simulations 100 --out-dir /tmp/mydatasets
python Creating_datasets.py --dgp slight --alpha 1 --n 250 --num-simulations 100 --out-dir ../main_ablation/DGP3_slight/alpha_1/datasets
```

## Options

- `--dgp {extreme,moderate,slight,all}` — target selection regime (see paper Eq. π_extreme/moderate/slight)
- `--alpha {1,2,4}` — baseline dominance; `alpha=4` is paper main (toughest RIC)
- `--n` — sample size; main paper uses 250, conditional uses 100/500/1000/10000
- `--num-simulations` — 100 per paper
- `--out-dir` — where to write `dataset_1_N{n}.csv` … `dataset_100_N{n}.csv`

Columns: `y, X1..Xp, w, tau, b, e, ate` (e = true propensity, tau = true CATE).

## Legacy

`legacy/` keeps the three original per-DGP scripts exactly as run in 2024, for provenance. They differ only in the `e = ...` line and `alpha` constant. New code should use the unified `Creating_datasets.py`.

## Conditional ablation note

For `p > 5` (covariate dimension), see `conditional_ablation/scripts/BCF_covariates_template.R` and `varying_covariates/Dataset.ipynb` — the generalized simulator sums baseline contributions in blocks of 5, so p must be multiple of 5. Timings in `details.txt`.
