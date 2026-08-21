# Sigmoid function (equivalent to Python's numpy version)
sigmoid <- function(x) {
  return(1 / (1 + exp(-x)))
}

# Function to simulate data specifically for mode = 5
# This directly implements the logic from Python's
# `simulate_extreme_propensity_difficult_baseline`
simulate_data_mode5 <- function(n = 1000, p = 5, sigma = 1.0) {

  # Check for minimum number of covariates (as implied by Python's MIN_COVARIATES)
  if (p < 5) {
    stop("Number of covariates (p) should be at least 5.")
  }

  # Generate covariates
  # Python: X = np.random.uniform(size=n * p).reshape((n, -1))
  X <- matrix(runif(n * p), nrow = n, ncol = p)

  # Calculate expected outcome (baseline) 'b'
  # Python: b = (
  #             np.sin(np.pi * X[:, 3])  # 4th column in Python
  #             + 2 * (X[:, 2] - 0.5) ** 2 # 3rd column in Python
  #             + np.min(X[:, :2], axis=1) # 1st and 2nd columns in Python, row-wise min
  #             + 0.5 * X[:, 4] # 5th column in Python
  #           )
  # R is 1-indexed
  b <- (
    sin(pi * X[, 4]) # Corresponds to Python's X[:, 3]
    + 2 * (X[, 3] - 0.5)^2 # Corresponds to Python's X[:, 2]
    + apply(X[, 1:2, drop = FALSE], 1, min) # Row-wise min of first two columns (Python's X[:, :2])
    + 0.5 * X[, 5] # Corresponds to Python's X[:, 4]
  )

  # Calculate propensity score 'e'
  # Python: e = 0.05 + 0.9 * beta.cdf(sigmoid(b), 2, 4)
  # scipy.stats.beta.cdf(x, a, b) is pbeta(x, shape1=a, shape2=b) in R
  e <- 0.05 + 0.9 * pbeta(sigmoid(b), shape1 = 2, shape2 = 4)

  # Alpha value (as in Python code)
  alpha <- 4

  # Calculate individual treatment effect 'tau'
  # Python: tau = (X[:, 0] + X[:, 1]) / (2*alpha) # 1st and 2nd columns in Python
  tau <- (X[, 1] + X[, 2]) / (2 * alpha) # Corresponds to Python's X[:, 0] and X[:, 1]

  # Simulate treatment assignment 'w'
  # Python: w = np.random.binomial(1, e, size=n)
  # In R, rbinom(n, size, prob): n is number of obs, size is number of trials for each.
  w <- rbinom(n, size = 1, prob = e)

  # Simulate outcome variable 'y'
  # Python: y = b + (w - 0.5) * tau + sigma * np.random.normal(size=n)
  # np.random.normal(size=n) gives N(0,1) by default.
  y <- b + (w - 0.5) * tau + sigma * rnorm(n, mean = 0, sd = 1)

  # Calculate Average Treatment Effect 'ate'
  # Python: ate = np.mean(tau)
  ate <- mean(tau)

  # Return results as a named list (R equivalent of Python's tuple)
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

number_of_points_list <- c(100,500)

for (j in number_of_points_list) {
number_experiments <- 100
number_of_points <- j
num_gfr <- 40
num_burnin <- 0
num_mcmc <- 1000

data <- simulate_data_mode5(n = number_of_points, p = 5, sigma = 0.5)
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
data <- simulate_data_mode5(n = number_of_points, p = 5, sigma = 0.5)
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

file_path <- paste0("BCF(no_pi_hat)", "_N", j,".xlsx")
write.xlsx(df, file_path, rowNames = FALSE)

}



