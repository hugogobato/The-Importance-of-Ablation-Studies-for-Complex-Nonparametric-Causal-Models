# Main Ablation Study

This folder reproduces **Table 1** and Figure *t_test_results_p_value_by_DGP* from the paper.

- **DGP1_extreme** (extreme target selection): `pi = 0.05 + 0.9*BetaCDF(sigmoid(b))`
- **DGP2_moderate** (moderate): `pi = 0.05 + 0.75*BetaCDF(sigmoid(b)) + 0.15*BetaCDF(min(X1,X2))`
- **DGP3_slight** (slight): `pi = 0.05 + 0.9*BetaCDF(min(X1,X2))`

Each DGP has three `alpha` subfolders:

| alpha | tau scaling          | baseline dominance | N in this repo |
|-------|----------------------|--------------------|----------------|
| 1     | (X1+X2)/2            | ~3x                | 100,250,500 (original N sweep, now `alpha_1`) |
| 2     | (X1+X2)/(4)          | ~7x                | 250 |
| 4     | (X1+X2)/(8)          | ~13x (paper main)  | 250 |

**Paper Table 1 = `DGP*_*/alpha_4` at N=250, 100 replications.** `alpha=1,2` give identical null results and are kept for completeness.

Per `alpha_*` folder:
- `Creating_datasets.py` — original generator (for provenance); use `../../data_generation/Creating_datasets.py` for unified runs
- `BCF_N250.R` — BCF with estimated pi_hat (bart)
- `BCF (no_pi_hat)_N250.R` — ablation (pi=0.5)
- `BCF(pi_oracle)_N250.R` — oracle true pi
- `Results_Summary.R` / `Statistical_tests(N=250).R` — aggregation & Welch tests
- `*.xlsx` — per-replication metrics (already committed)
- `Results.txt`, `N250_Statistical_Tests.txt` — precomputed paper numbers
- `Boxplots_*.png`, `Density_Plots_*.png` — diagnostic plots
- `example_dataset.csv` + `DATASETS_NOTE.md` — one illustrative raw CSV (bulk datasets regenerated via generator)

Run order per DGP/alpha:
1. `python ../../data_generation/Creating_datasets.py --dgp {extreme,moderate,slight} --alpha 4 --n 250 --out-dir .`
2. `Rscript ../../scripts/BCF_N250.R` (and the two variants)
3. `Rscript ../../scripts/Results_Summary.R && Rscript ../../scripts/Statistical_tests.R`
