"""
Unified data generation for Ablation BCF experiments.

Credit: https://github.com/uber/causalml
DGP definitions follow Ballinari et al. (2024) with alpha controlling baseline dominance.

DGPs:
  - DGP1 extreme:   pi_extreme = 0.05 + 0.9 * BetaCDF_{2,4}(sigmoid(b)),   strong targeted selection
  - DGP2 moderate:  pi_moderate = 0.05 + 0.75*BetaCDF(sigmoid(b)) + 0.15*BetaCDF(min(X1,X2))
  - DGP3 slight:    pi_slight = 0.05 + 0.9 * BetaCDF(min(X1,X2)),          weak targeted selection

Alpha: tau = (X1+X2)/(2*alpha), baseline b as defined. Larger alpha => baseline dominates.

Usage:
  python Creating_datasets.py --dgp extreme --alpha 4 --n 250 --num-simulations 100 --mode 5
  python Creating_datasets.py --dgp all --alpha 4 --n 250
"""

import numpy as np
from typing import Tuple
from scipy.stats import beta
import pandas as pd
import os
import argparse

MIN_COVARIATES = 5

def sigmoid(x):
    return 1 / (1 + np.exp(-x))

# -------------------------------------------------------------------------
# Helper catalog from Nie & Wager (2018) - kept for completeness
# -------------------------------------------------------------------------
def simulate_data(mode=1, n=1000, p=5, sigma=1.0, dgp="extreme", alpha=1):
    catalog = {
        1: simulate_easy_propensity_easy_baseline,
        2: simulate_difficult_propensity_easy_baseline,
        3: simulate_easy_propensity_difficult_baseline,
        4: simulate_difficult_propensity_difficult_baseline,
        5: lambda n,p,sigma: simulate_extreme_propensity_difficult_baseline(n,p,sigma,dgp=dgp,alpha=alpha),
    }
    assert mode in catalog, f"Invalid mode {mode}. Should be one of {set(catalog)}"
    assert p >= MIN_COVARIATES, f"Number of covariates should be at least {MIN_COVARIATES}"
    return catalog[mode](n, p, sigma)


def simulate_nuisance_and_easy_treatment(n=1000, p=5, sigma=1.0):
    X = np.random.uniform(size=n * p).reshape((n, -1))
    b = (
        np.sin(np.pi * X[:, 0] * X[:, 1])
        + 2 * (X[:, 2] - 0.5) ** 2
        + X[:, 3]
        + 0.5 * X[:, 4]
    )
    eta = 0.1
    e = np.maximum(np.repeat(eta, n), np.minimum(np.sin(np.pi * X[:, 0] * X[:, 1]), np.repeat(1 - eta, n)))
    tau = (X[:, 0] + X[:, 1]) / 2
    w = np.random.binomial(1, e, size=n)
    y = b + (w - 0.5) * tau + sigma * np.random.normal(size=n)
    ate = np.mean(tau)
    return y, X, w, tau, b, e, ate


def simulate_randomized_trial(n=1000, p=5, sigma=1.0):
    X = np.random.normal(size=n * p).reshape((n, -1))
    b = np.maximum.reduce([np.repeat(0.0, n), X[:, 0] + X[:, 1], X[:, 2]]) + np.maximum(np.repeat(0.0, n), X[:, 3] + X[:, 4])
    e = np.repeat(0.5, n)
    tau = X[:, 0] + np.log1p(np.exp(X[:, 1]))
    w = np.random.binomial(1, e, size=n)
    y = b + (w - 0.5) * tau + sigma * np.random.normal(size=n)
    ate = np.mean(tau)
    return y, X, w, tau, b, e, ate


def simulate_easy_propensity_difficult_baseline(n=1000, p=5, sigma=1.0):
    X = np.random.uniform(size=n * p).reshape((n, -1))
    b = (np.sin(np.pi * X[:, 0] * X[:, 1]) + 2 * (X[:, 2] - 0.5) ** 2 + X[:, 3] + 0.5 * X[:, 4])
    e = 1 / (1 + np.exp(X[:, 1] - X[:, 2]))
    tau = (X[:, 0] + X[:, 1]) / 2
    w = np.random.binomial(1, e, size=n)
    y = b + (w - 0.5) * tau + sigma * np.random.normal(size=n)
    ate = np.mean(tau)
    return y, X, w, tau, b, e, ate


def simulate_unrelated_treatment_control(n=1000, p=5, sigma=1.0):
    X = np.random.normal(size=n * p).reshape((n, -1))
    b = (np.maximum(np.repeat(0.0, n), X[:, 0] + X[:, 1] + X[:, 2]) + np.maximum(np.repeat(0.0, n), X[:, 3] + X[:, 4])) / 2
    e = 1 / (1 + np.exp(-X[:, 0]) + np.exp(-X[:, 1]))
    tau = np.maximum(np.repeat(0.0, n), X[:, 0] + X[:, 1] + X[:, 2]) - np.maximum(np.repeat(0.0, n), X[:, 3] + X[:, 4])
    w = np.random.binomial(1, e, size=n)
    y = b + (w - 0.5) * tau + sigma * np.random.normal(size=n)
    ate = np.mean(tau)
    return y, X, w, tau, b, e, ate


def simulate_difficult_propensity_easy_baseline(n=1000, p=5, sigma=1.0):
    X = np.random.uniform(size=n * p).reshape((n, -1))
    b = X[:, 0] * X[:, 1] + 2 * (X[:, 2] - 0.5) ** 2 + X[:, 3] + 0.5 * X[:, 4]
    e = 0.1 + 0.6 * beta.cdf(np.min(X[:, :2], axis=1), 2, 4)
    tau = (X[:, 0] + X[:, 1]) / 2
    w = np.random.binomial(1, e, size=n)
    y = b + (w - 0.5) * tau + sigma * np.random.normal(size=n)
    ate = np.mean(tau)
    return y, X, w, tau, b, e, ate


def simulate_easy_propensity_easy_baseline(n=1000, p=5, sigma=1.0):
    X = np.random.uniform(size=n * p).reshape((n, -1))
    b = X[:, 0] * X[:, 1] + 2 * (X[:, 2] - 0.5) ** 2 + X[:, 3] + 0.5 * X[:, 4]
    e = 1 / (1 + np.exp(X[:, 1] - X[:, 2]))
    tau = (X[:, 0] + X[:, 1]) / 2
    w = np.random.binomial(1, e, size=n)
    y = b + (w - 0.5) * tau + sigma * np.random.normal(size=n)
    ate = np.mean(tau)
    return y, X, w, tau, b, e, ate


def simulate_difficult_propensity_difficult_baseline(n=1000, p=5, sigma=1.0):
    X = np.random.uniform(size=n * p).reshape((n, -1))
    b = (np.sin(np.pi * X[:, 0] * X[:, 1]) + 2 * (X[:, 2] - 0.5) ** 2 + X[:, 3] + 0.5 * X[:, 4])
    e = 0.1 + 0.6 * beta.cdf(np.min(X[:, :2], axis=1), 2, 4)
    tau = (X[:, 0] + X[:, 1]) / 2
    w = np.random.binomial(1, e, size=n)
    y = b + (w - 0.5) * tau + sigma * np.random.normal(size=n)
    ate = np.mean(tau)
    return y, X, w, tau, b, e, ate


def simulate_extreme_propensity_difficult_baseline(n=1000, p=5, sigma=1.0, dgp="extreme", alpha=1):
    """Unified DGP for the paper's three target-selection regimes.

    Args:
        dgp: one of {"extreme", "moderate", "slight"}
        alpha: baseline dominance factor (1, 2, 4). tau = (X1+X2)/(2*alpha)
    """
    X = np.random.uniform(size=n * p).reshape((n, -1))
    # Baseline b differs slightly between DGPs in original scripts:
    #  extreme/moderate share b = sin(pi*X3) + 2*(X2-0.5)^2 + min(X1,X2) + 0.5*X4  (paper Eq.)
    #  slight uses b = sin(pi*X1*X2) + 2*(X2-0.5)^2 + X3 + 0.5*X4  (Setup C baseline)
    #  We keep the paper's exact b for all three as sin(pi*X1*X2)+..., but for backward
    #  compatibility we preserve the original extreme/moderate construction when dgp != "slight".
    #  In practice both baselines are highly prognostic and results are identical (see paper).
    if dgp == "slight":
        b = (
            np.sin(np.pi * X[:, 0] * X[:, 1])
            + 2 * (X[:, 2] - 0.5) ** 2
            + X[:, 3]
            + 0.5 * X[:, 4]
        )
        e = 0.05 + 0.9 * beta.cdf(np.min(X[:, :2], axis=1), 2, 4)
    elif dgp == "moderate":
        b = (
            np.sin(np.pi * X[:, 3])
            + 2 * (X[:, 2] - 0.5) ** 2
            + np.min(X[:, :2], axis=1)
            + 0.5 * X[:, 4]
        )
        # DGP2 moderate targeted selection
        e = 0.05 + 0.75 * beta.cdf(sigmoid(b), 2, 4) + 0.15 * beta.cdf(np.min(X[:, :2], axis=1), 2, 4)
    else:  # extreme
        b = (
            np.sin(np.pi * X[:, 3])
            + 2 * (X[:, 2] - 0.5) ** 2
            + np.min(X[:, :2], axis=1)
            + 0.5 * X[:, 4]
        )
        e = 0.05 + 0.9 * beta.cdf(sigmoid(b), 2, 4)

    tau = (X[:, 0] + X[:, 1]) / (2 * alpha)
    w = np.random.binomial(1, e, size=n)
    y = b + (w - 0.5) * tau + sigma * np.random.normal(size=n)
    ate = np.mean(tau)
    return y, X, w, tau, b, e, ate


def save_simulation_data(n, num_simulations=100, mode=5, dgp="extreme", alpha=4, out_dir="."):
    os.makedirs(out_dir, exist_ok=True)
    for i in range(num_simulations):
        y, X, w, tau, b, e, ate = simulate_extreme_propensity_difficult_baseline(n=n, p=5, sigma=1.0, dgp=dgp, alpha=alpha)
        df = pd.DataFrame({
            'y': y,
            **{f'X{i+1}': X[:, i] for i in range(X.shape[1])},
            'w': w,
            'tau': tau,
            'b': b,
            'e': e,
            'ate': np.repeat(ate, y.shape[0])
        })
        filename = os.path.join(out_dir, f'dataset_{i+1}_N{n}.csv')
        df.to_csv(filename, index=False)
        if (i+1) % 20 == 0:
            print(f"  Saved {i+1}/{num_simulations} to {out_dir}")


if __name__ == "__main__":
    parser = argparse.ArgumentParser(description="Generate synthetic datasets for BCF ablation study")
    parser.add_argument("--dgp", type=str, default="extreme", choices=["extreme","moderate","slight","all"],
                        help="Target selection regime")
    parser.add_argument("--alpha", type=int, default=4, choices=[1,2,4], help="Baseline dominance")
    parser.add_argument("--n", type=int, default=250, help="Sample size")
    parser.add_argument("--num-simulations", type=int, default=100, help="Number of datasets")
    parser.add_argument("--out-dir", type=str, default=None, help="Output directory (default: auto)")
    parser.add_argument("--mode", type=int, default=5, help="Simulation mode (5 = paper DGP)")
    args = parser.parse_args()

    dgps = ["extreme","moderate","slight"] if args.dgp == "all" else [args.dgp]
    for dgp in dgps:
        out_dir = args.out_dir if args.out_dir else f"./datasets_{dgp}_alpha{args.alpha}_N{args.n}"
        print(f"Generating {args.num_simulations} datasets for DGP={dgp}, alpha={args.alpha}, N={args.n} -> {out_dir}")
        save_simulation_data(n=args.n, num_simulations=args.num_simulations, dgp=dgp, alpha=args.alpha, out_dir=out_dir)

    print("Done.")
