# Load the necessary packages
library(RVAideMemoire)
library(readxl)
library(dplyr)
library(car)
library(MASS)
library(coin)

# Load the datasets
bcf <- read_excel("BCF_N500.xlsx")
ps_bart <- read_excel("BCF(no_pi_hat)_N500.xlsx")

# Calculate SE and AE for 'ATE_cover' and 'CATE_cover'
bcf$SE_ATE_cover <- (0.95 - bcf$ATE_cover)^2
bcf$AE_ATE_cover <- abs(0.95 - bcf$ATE_cover)

bcf$SE_CATE_cover <- (0.95 - bcf$CATE_cover)^2
bcf$AE_CATE_cover <- abs(0.95 - bcf$CATE_cover)

# Calculate the mean and standard deviation for each column
mean_values <- colMeans(bcf, na.rm = TRUE)
std_values <- apply(bcf, 2, sd, na.rm = TRUE)

# Redirect output to a text file
sink("N500_Statistical_Tests.txt")

# Print the results
cat("BCF\n")
cat("Mean of each column:\n")
print(mean_values)
cat("\nStandard deviation of each column:\n")
print(std_values)

# Calculate SE and AE for 'ATE_cover' and 'CATE_cover'
ps_bart$SE_ATE_cover <- (0.95 - ps_bart$ATE_cover)^2
ps_bart$AE_ATE_cover <- abs(0.95 - ps_bart$ATE_cover)

ps_bart$SE_CATE_cover <- (0.95 - ps_bart$CATE_cover)^2
ps_bart$AE_CATE_cover <- abs(0.95 - ps_bart$CATE_cover)

# Calculate the mean and standard deviation for each column
mean_values <- colMeans(ps_bart, na.rm = TRUE)
std_values <- apply(ps_bart, 2, sd, na.rm = TRUE)

# Print the results
cat("BCF(no_pi_hat)")
cat("Mean of each column:\n")
print(mean_values)
cat("\nStandard deviation of each column:\n")
print(std_values)

# Function to check normality using Shapiro-Wilk test
check_normality <- function(data) {
  p_value <- shapiro.test(data)$p.value
  return(p_value > 0.05)  # If p > 0.05, data is normally distributed
}

# Function to check homoscedasticity using Levene's test
check_homoscedasticity <- function(data1, data2) {
  data <- data.frame(value = c(data1, data2), group = factor(rep(1:2, times = c(length(data1), length(data2)))))
  p_value <- leveneTest(value ~ group, data = data, center=mean)$'Pr(>F)'[1]
  return(p_value > 0.05)  # If p > 0.05, variances are equal
}

considered_indexes = c(1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 13, 14, 15, 16)
# Loop through each considered index
for (i in considered_indexes) {
  group1 <- as.numeric(unlist(ps_bart[, i]))
  group2 <- as.numeric(unlist(bcf[, i]))
  
  normality1 <- check_normality(group1)
  normality2 <- check_normality(group2)
  homoscedasticity <- check_homoscedasticity(group1, group2)
  
  cat(sprintf("For %s\n", colnames(ps_bart)[i]))
  
  if (normality1 && normality2 && homoscedasticity) {
    t_test <- t.test(group1, group2)$p.value
    f_test <- var.test(group1, group2)$p.value
    
    cat("T-test:\n")
    print(t_test)
    cat("F-test:\n")
    print(f_test)
  } else {
    data <- data.frame(value = c(group1, group2), group = factor(rep(1:2, times = c(length(group1), length(group2)))))
    
    if (homoscedasticity) {
      mann_whitney_u_test <- wilcox.test(group1, group2)$p.value
      kruskal_wallis_h_test <- kruskal.test(list(group1, group2))$p.value
      levene_test <- leveneTest(value ~ group, data = data, center = mean)$'Pr(>F)'[1]
      brown_forsythe_test <- leveneTest(value ~ group, data = data, center = median)$'Pr(>F)'[1]
      
      cat("Mann-Whitney U Test:\n")
      print(mann_whitney_u_test)
      cat("Kruskal-Wallis H Test:\n")
      print(kruskal_wallis_h_test)
      cat("Levene's Test:\n")
      print(levene_test)
      cat("Brown-Forsythe Test:\n")
      print(brown_forsythe_test)
    } else {
      fligner_policello_test <- fp.test(group1, group2)$p.value
      levene_test <- leveneTest(value ~ group, data = data, center = mean)$'Pr(>F)'[1]
      brown_forsythe_test <- leveneTest(value ~ group, data = data, center = median)$'Pr(>F)'[1]
      
      cat("Fligner-Policello test:\n")
      print(fligner_policello_test)
      cat("Levene's Test:\n")
      print(levene_test)
      cat("Brown-Forsythe Test:\n")
      print(brown_forsythe_test)
    }
  }
}

