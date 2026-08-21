# Sigmoid function (equivalent to Python's numpy version)
sigmoid <- function(x) {
  return(1 / (1 + exp(-x)))
}

# Generalized function to simulate data
simulate_data_mode5_generalized <- function(n = 1000, p = 5, sigma = 1.0) {

  # Check for minimum number of covariates and if p is a multiple of 5
  if (p < 5) {
    stop("Number of covariates (p) should be at least 5.")
  }
  if (p %% 5 != 0) {
    stop("Number of covariates (p) must be a multiple of 5 for this generalization.")
  }

  # Generate covariates
  X <- matrix(runif(n * p), nrow = n, ncol = p)

  # Calculate expected outcome (baseline) 'b'
  # It will be the sum of contributions from each block of 5 covariates,
  # divided by the number of blocks to keep the average magnitude similar.

  num_blocks <- p / 5
  b_sum_contributions <- numeric(n) # Initialize a vector of zeros of length n

  for (k_block in 0:(num_blocks - 1)) {
    # Define the column indices for the current block
    # R is 1-indexed, so we add 1 to 0-indexed block calculations
    col_offset <- k_block * 5

    # Indices within X for the current block's terms
    # Relative to the start of the block, they are 1, 2, 3, 4, 5
    # Absolute column indices in X:
    idx_for_min1 <- col_offset + 1
    idx_for_min2 <- col_offset + 2
    idx_for_sq   <- col_offset + 3
    idx_for_sin  <- col_offset + 4
    idx_for_lin  <- col_offset + 5

    current_block_contribution <- (
      sin(pi * X[, idx_for_sin])
      + 2 * (X[, idx_for_sq] - 0.5)^2
      + apply(X[, c(idx_for_min1, idx_for_min2), drop = FALSE], 1, min)
      + 0.5 * X[, idx_for_lin]
    )
    b_sum_contributions <- b_sum_contributions + current_block_contribution
  }

  # Average the contributions
  b <- b_sum_contributions / num_blocks

  # Calculate propensity score 'e'
  e <- 0.05 + 0.9 * pbeta(sigmoid(b), shape1 = 2, shape2 = 4)

  # Alpha value (as in Python code)
  alpha <- 4

  # IMPORTANT: tau is defined based on the *first two* covariates X[,1] and X[,2]
  # regardless of p. This matches the original structure and ensures
  # the ATE definition doesn't change wildly with p.
  # If you wanted tau to also be an average over blocks, this part would need generalization too.
  tau <- (X[, 1] + X[, 2]) / (2 * alpha)

  w <- rbinom(n, size = 1, prob = e)

  y <- b + (w - 0.5) * tau + sigma * rnorm(n, mean = 0, sd = 1)

  # Calculate Average Treatment Effect 'ate'
  ate <- mean(tau)

  # Return results as a named list
  return(list(
    y = y,
    X = X,
    w = w,
    tau = tau,
    b = b,
    e = e,
    ate = ate
  ))
}

install.packages("stochtree")

install.packages("dbarts")

install.packages("openxlsx")

library(stochtree)
library(dbarts)

num_covariates_list <- c(10)

for (j in num_covariates_list) {
number_experiments <- 100
number_of_points <- 250
num_gfr <- 40
num_burnin <- 0
num_mcmc <- 1000
num_covariates <- j

data <- simulate_data_mode5_generalized(n = number_of_points, p = num_covariates, sigma = 0.5)
num_samples <- length(data$y)

ATE_RMSE <-numeric(number_experiments)
ATE_MAE <-numeric(number_experiments)
ATE_MAPE <-numeric(number_experiments)
ATE_len <-numeric(number_experiments)
ATE_cover <-numeric(number_experiments)

CATE_values <- matrix(nrow = num_samples, ncol = number_experiments)
CATE_RMSE <- numeric(number_experiments)
CATE_MAE <-numeric(number_experiments)
CATE_MAPE <-numeric(number_experiments)
CATE_len <-numeric(number_experiments)
CATE_cover <-numeric(number_experiments)

pi_RMSE <- numeric(number_experiments)
pi_MAE <-numeric(number_experiments)

library(progress)

# Initialize progress bar
pb <- progress_bar$new(
  format = "  [:bar] :percent :elapsedfull",
  total = number_experiments, clear = FALSE, width = 60
)

for (i in 1:number_experiments) {

pb$tick() # Increment the progress bar

set.seed(i)
data <- simulate_data_mode5_generalized(n = number_of_points, p = num_covariates, sigma = 0.5)
Y <- data$y
X <- data$X
D <- data$w
tau <- data$tau
ate <- data$ate

pi_hats <- rep(0.5, number_of_points)

pi_RMSE[i] <- sqrt(mean((pi_hats - data$e)^2))
pi_MAE[i] <- mean(abs(pi_hats - data$e))

dbfit <- bcf(
    X_train = X, Z_train = D, y_train = Y, propensity_train = pi_hats, num_gfr = num_gfr, num_burnin = num_burnin, num_mcmc = num_mcmc)

sample_inds <- (num_gfr + num_burnin + 1):num_mcmc

CATE_hat_simulations <- dbfit$tau_hat_train[,sample_inds]
CATE_hat <- rowMeans(CATE_hat_simulations)

# Calculate the 2.5th and 97.5th percentiles for each datapoint across simulations
lower_bounds <- apply(CATE_hat_simulations, 1, function(x) quantile(x, probs = 0.025))
upper_bounds <- apply(CATE_hat_simulations, 1, function(x) quantile(x, probs = 0.975))

CATE_len[i] <- mean(abs(upper_bounds-lower_bounds))

CATE_RMSE[i] <- sqrt(mean((tau - CATE_hat)^2))
CATE_MAE[i] <- mean(abs(tau - CATE_hat))
CATE_MAPE[i] <- mean(abs(tau - CATE_hat)/abs(tau))


cover_vector <- (tau >= lower_bounds) & (tau <= upper_bounds)
number_covered <- sum(cover_vector)

CATE_cover[i]<- number_covered / length(tau)
CATE_values[, i] = CATE_hat
ATE_hat <- mean(CATE_hat)

ATE_RMSE[i] <- sqrt(mean((ate - ATE_hat)^2))
ATE_MAE[i] <- mean(abs(ate - ATE_hat))
ATE_MAPE[i] <- mean(abs(ate - ATE_hat)/abs(ate))

ATE_hat_simulations <- colMeans(CATE_hat_simulations)

ATE_lower_bound <- quantile(ATE_hat_simulations, probs = 0.025)
ATE_upper_bound <- quantile(ATE_hat_simulations, probs = 0.975)
ATE_CI <- c(ATE_lower_bound, ATE_upper_bound)
ATE_cover[i] <- ifelse(mean(tau) >= ATE_CI[1] && mean(tau) <= ATE_CI[2], 1, 0)
ATE_len[i] <- abs(ATE_lower_bound- ATE_upper_bound)

}

cat(sprintf("ATE RMSE Mean: %f, ATE RMSE SD: %f, ", mean(ATE_RMSE), sd(ATE_RMSE)))
cat("\n")
cat(sprintf("ATE MAE Mean: %f, ATE MAE SD: %f, ", mean(ATE_MAE), sd(ATE_MAE)))
cat("\n")
cat(sprintf("ATE MAPE Mean: %f, ATE MAPE SD: %f, ", mean(ATE_MAPE), sd(ATE_MAPE)))
cat("\n")
cat(sprintf("ATE Cover: %f, ", sum(ATE_cover)/length(ATE_cover)))
cat("\n")
cat(sprintf("ATE Length Mean: %f, ATE Length SD: %f, ", mean(ATE_len), sd(ATE_len)))
cat("\n")
cat(sprintf("CATE RMSE Mean: %f, CATE RMSE SD: %f, ", mean(CATE_RMSE), sd(CATE_RMSE)))
cat("\n")
cat(sprintf("CATE MAE Mean: %f, CATE MAE SD: %f, ", mean(CATE_MAE), sd(CATE_MAE)))
cat("\n")
cat(sprintf("CATE MAPE Mean: %f, CATE MAPE SD: %f, ", mean(CATE_MAPE), sd(CATE_MAPE)))
cat("\n")
cat(sprintf("CATE Cover Mean: %f, CATE Cover SD: %f, ", mean(CATE_cover), sd(CATE_cover)))
cat("\n")
cat(sprintf("CATE Length Mean: %f, CATE Length SD: %f ", mean(CATE_len), sd(CATE_len)))
cat("\n")
cat(sprintf("Pi(X) RMSE Mean: %f, Pi(X) RMSE SD: %f, ", mean(pi_RMSE), sd(pi_RMSE)))
cat("\n")
cat(sprintf("Pi(X) MAE Mean: %f, Pi(X) MAE SD: %f, ", mean(pi_MAE), sd(pi_MAE)))
cat("\n")

# Creating a dataframe
df <- data.frame(
  CATE_RMSE = CATE_RMSE,
  CATE_MAE = CATE_MAE,
  CATE_MAPE = CATE_MAPE,
  CATE_cover = CATE_cover,
  CATE_len = CATE_len,
  ATE_RMSE = ATE_RMSE,
  ATE_MAE = ATE_MAE,
  ATE_MAPE = ATE_MAPE,
  ATE_cover = ATE_cover,
  ATE_len = ATE_len,
  pi_RMSE = pi_RMSE,
  pi_MAE = pi_MAE
)

library(openxlsx)

file_path <- paste0("BCF(no_pi_hat)", "_num_covariates_", j,".xlsx")
write.xlsx(df, file_path, rowNames = FALSE)

}



