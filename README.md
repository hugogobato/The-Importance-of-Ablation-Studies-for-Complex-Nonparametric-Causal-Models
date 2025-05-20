# The-Importance-of-Ablation-Studies-for-Complex-Nonparametric-Causal-Models

This is the Github Repository for the paper titled "The Importance of Ablation Studies for Complex Nonparametric Causal Models" of Hugo Gobato Souto<sup>1</sup> and Francisco Louzada<sup>2</sup>

<sup>1</sup> Institute of Mathematics and Computer Sciences at University of Sao Paulo, Brazil. hgsouto@usp.br. https://orcid.org/0000-0002-7039-0572

<sup>2</sup> Institute of Mathematics and Computer Sciences at University of Sao Paulo, Brazil. louzada@icmc.usp.br. https://orcid.org/0000-0001-7815-9554

## Abstract
Ablation studies are essential for understanding the contribution of individual components within complex models, yet their application in nonparametric treatment effect estimation remains limited. This paper emphasizes the importance of ablation studies by examining the Bayesian Causal Forest (BCF) model, particularly the inclusion of the estimated propensity score $\hat{\pi}}$ πˆ(xi) intended to mitigate regularization-induced confounding (RIC). Through a partial ablation study utilizing a total of nine synthetic, we demonstrate that excluding πˆ(xi) does not diminish the model’s performance in estimating average and conditional average treatment effects or in uncertainty quantification. Moreover, omitting πˆ(xi) reduces computational time by approximately 21%. These findings could suggest that the BCF model’s inherent flexibility suffices in adjusting for confounding without explicitly incorporating the propensity score. The study advocates for the routine use of ablation studies in treatment effect estimation to ensure model components are essential and to prevent unnecessary complexity.

## Citation
```bibtex
@misc{https://doi.org/10.48550/arxiv.2410.15560,
  doi = {10.48550/ARXIV.2410.15560},
  url = {https://arxiv.org/abs/2410.15560},
  author = {Souto,  Hugo Gobato and Louzada,  Francisco},
  keywords = {Methodology (stat.ME),  Machine Learning (stat.ML),  FOS: Computer and information sciences,  FOS: Computer and information sciences},
  title = {Ablation Studies for Novel Treatment Effect Estimation Models},
  publisher = {arXiv},
  year = {2024},
  copyright = {Creative Commons Attribution Non Commercial Share Alike 4.0 International}
}





