# Legacy Folder

This `Experiments/` folder is preserved for backward compatibility with the
original submission (commits up to 96d9097). New users should use the **clean
structure** at the repository root:

- `main_ablation/DGP1_extreme|DGP2_moderate|DGP3_slight/{alpha_1,alpha_2,alpha_4}/`
- `conditional_ablation/{varying_sample_size,varying_mu_trees,varying_covariates}/`
- `data_generation/Creating_datasets.py` (unified generator)
- `images/` and `generate_plots.py`

All `*.xlsx`, `*.R`, and `*.ipynb` in this `Experiments/` folder are duplicated
in the clean folders (with corrected names, e.g. `DGP1_extreme/alpha_1` instead
of `DGP1/alpha=1`, and `BCF(pi_hat)_part_1_cov_p5.ipynb` fixed). The clean
folders additionally contain `Boxplots_*.png`, `Statistical_tests`, `Results.txt`,
and `example_dataset.csv` that were removed from the bulky `dataset_*.csv`
shards.

This folder will be kept for one release cycle and may be removed in a future
cleanup. See `README.md` (root) for full reproduction instructions.
