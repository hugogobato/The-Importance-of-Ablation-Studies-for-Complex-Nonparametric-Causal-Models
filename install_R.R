# R dependencies for BCF ablation study
# Run: Rscript install_R.R

install_if_missing <- function(pkg) {
  if (!requireNamespace(pkg, quietly=TRUE)) {
    install.packages(pkg, repos="https://cloud.r-project.org")
  }
}
pkgs <- c("stochtree","dbarts","openxlsx","readxl","ggplot2","reshape2","dplyr","progress","RVAideMemoire","car","MASS","coin")
for (p in pkgs) install_if_missing(p)
cat("All R packages installed. For stochtree, see https://github.com/StochasticTree/stochtree\n")
