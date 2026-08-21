if(!require(readxl)) install.packages("readxl")
if(!require(reshape2)) install.packages("reshape2")
if(!require(ggplot2)) install.packages("ggplot2")

library(readxl)
library(reshape2)
library(ggplot2)
library(dplyr)

# Redirect output to a text file
sink("Results.txt")

process_N <- function(N) {
  # Prepare file names
  files <- paste0(c("BCF_", "BCF(pi_oracle)_", "BCF(no_pi_hat)_"), "N", N, ".xlsx")
  
  # Read data and add Source column
  data_list <- lapply(files, function(file) {
    data <- read_excel(file)
    data$Source <- gsub(".xlsx", "", file)
    # Calculate SE_CATE_cover and AE_CATE_cover
    data$SE_CATE_cover <- (0.95 - data$CATE_cover)^2
    data$AE_CATE_cover <- abs(0.95 - data$CATE_cover)
    return(data)
  })
  
  combined_data <- do.call(rbind, data_list)

  # Melt data into long format
  melted_data <- melt(combined_data, id.vars = "Source")
  
  # Compute mean and standard deviation per Model (Source) and Variable
  mean_std_df <- melted_data %>%
    group_by(Source, variable) %>%
    summarise(
      Mean = mean(value, na.rm = TRUE),
      StdDev = sd(value, na.rm = TRUE)
    ) %>%
    ungroup()
  
  # Print the mean and std table
  print(mean_std_df, n = Inf)
  
  # Exclude SE_CATE_cover and AE_CATE_cover from box plots
  boxplot_vars <- setdiff(unique(melted_data$variable), c("SE_CATE_cover", "AE_CATE_cover"))
  boxplot_data <- subset(melted_data, variable %in% boxplot_vars)
  
  # Boxplots without SE_CATE_cover and AE_CATE_cover
  boxplot_file <- paste0("Boxplots_N", N, ".png")
  png(boxplot_file, width = 1200, height = 800)
  print(ggplot(boxplot_data, aes(x=Source, y=value)) +
    geom_boxplot() +
    facet_wrap(~variable, scales="free") +
    theme_bw() +
    theme(axis.text.x = element_text(angle=45, hjust=1)) +
    labs(title = paste("alpha=4"), x = "Source File", y = "Value"))
  dev.off()
  
  # Density plots for CATE_cover
  subset_vars <- subset(melted_data, variable %in% c("CATE_cover"))
  
  density_plot_file <- paste0("Density_Plots_N", N, ".png")
  png(density_plot_file, width = 800, height = 400)
  print(ggplot(subset_vars, aes(x=value, color=Source)) +
    geom_density() +
    facet_wrap(~variable, scales="free") +
    theme_bw() +
    labs(title = paste("Density Plots for CATE_cover N=", N), x = "Value", y = "Density"))
  dev.off()
  
}

# Process data for N=100, N=250, and N=500
process_N(250)
