library(stochtree)
library(dbarts)

number_experiments <- 10
number_of_points <- 250
num_gfr <- 40
num_burnin <- 0
num_mcmc <- 1000

data<-read.csv( paste0("dataset_", 1, "_N", number_of_points,".csv"))
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

for (i in 1:number_experiments) {

file_name <- paste0("dataset_", i, "_N", number_of_points,".csv")
data<-read.csv(file_name)
Y <- data$y
X <- data[, !(names(data) %in% c("y", "tau","w", "b", "e","ate"))]
D <- data$w
tau <- data$tau
ate <- data$ate

dbfit <- bart(X,D,X,verbose=F)
pi_hats <- pnorm(colMeans(dbfit$yhat.test))

pi_RMSE[i] <- sqrt(mean((pi_hats - data$e)^2))
pi_MAE[i] <- mean(abs(pi_hats - data$e))

dbfit <- bcf(
    X_train = X, Z_train = D, y_train = Y, pi_train = pi_hats, num_gfr = num_gfr, num_burnin = num_burnin, num_mcmc = num_mcmc)

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

cat(sprintf("Iteration %f completed, ", as.integer(i)))

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

paste0("dataset_", i, "_N", number_of_points,".csv")

file_path <- paste0("BCF", "_N", number_of_points,".xlsx")
write.xlsx(df, file_path, rowNames = FALSE)

# Create a new workbook
wb <- createWorkbook()

# Add sheets with matrices
addWorksheet(wb, "CATE_values")
writeData(wb, "CATE_values", CATE_values)

# Save the workbook as an Excel file
saveWorkbook(wb, paste0("BCF_CATE_values", "_N", number_of_points,".xlsx"), overwrite = TRUE)