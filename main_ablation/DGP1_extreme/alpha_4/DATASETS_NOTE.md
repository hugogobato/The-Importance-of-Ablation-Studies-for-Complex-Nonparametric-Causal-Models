# Datasets

Original experiments generated 100 synthetic datasets per configuration (N=250 for alpha=2,4; N=100,250,500 for alpha=1).
To keep the repository lightweight, bulk `dataset_*.csv` files are not stored.
Run `python ../../data_generation/Creating_datasets.py` to regenerate them.
An `example_dataset.csv` is included for inspection.
Original total: 100 datasets of size 47.8 KB each.
Columns: y (outcome), X1-X5 (covariates), w (treatment), tau (true CATE), b (prognostic), e (true propensity), ate.
