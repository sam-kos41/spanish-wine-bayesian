#!/usr/bin/env Rscript

#' Spanish Wine Regions - Bayesian Analysis
#' Run this script instead of the .Rmd if you don't have pandoc
#' 
#' Usage: source("run_analysis.R")

cat("===============================================\n")
cat("Spanish Wine Regions - Bayesian Analysis\n")
cat("===============================================\n\n")

# Set parameters
BUDGET_MODE <- TRUE  # Change to FALSE for all prices
SEED <- 1

# Load libraries
cat("Loading libraries...\n")
suppressPackageStartupMessages({
  library(dplyr)
  library(ggplot2)
  library(readr)
  library(tidyr)
  library(purrr)
  library(coda)
})

# Source custom functions
source("R/gibbs_hier_normal.R")

# Create output directories
dir.create("figs", showWarnings = FALSE)
dir.create("outputs", showWarnings = FALSE)

# Set seed
set.seed(SEED)

# Set theme
theme_set(theme_minimal(base_size = 12))

# ========================================
# 1. LOAD DATA
# ========================================
cat("\n1. Loading data...\n")

data_path <- "data/winemag-data-130k-v2.csv"

if (!file.exists(data_path)) {
  stop("Data file not found. Please download from Kaggle and place in data/ folder\n",
       "URL: https://www.kaggle.com/zynicide/wine-reviews")
}

wine <- read_csv(data_path, show_col_types = FALSE, guess_max = 10000)

# Focus on five major Spanish wine regions
regions_keep <- c("Rioja", "Jerez", "Utiel-Requena", 
                  "Ribera del Duero", "Rías Baixas")

wine_es <- wine %>%
  filter(country == "Spain", 
         region_1 %in% regions_keep) %>%
  dplyr::select(region_1, variety, price, points) %>%
  mutate(region_1 = factor(region_1, levels = regions_keep))

# Apply price filter if in budget mode
if (BUDGET_MODE) {
  wine_es <- wine_es %>% 
    filter(between(price, 15, 20))
  cat("  Mode: Budget ($15-$20)\n")
} else {
  cat("  Mode: All prices\n")
}

cat("  Total wines:", nrow(wine_es), "\n")

# ========================================
# 2. PREPARE DATA BY REGION
# ========================================
cat("\n2. Preparing data by region...\n")

signature_variety <- list(
  "Rioja" = "Tempranillo Blend",
  "Jerez" = "Sherry",
  "Ribera del Duero" = "Tempranillo",
  "Rías Baixas" = "Albariño"
)

split_list <- split(wine_es, wine_es$region_1)

Y <- map2(split_list, names(split_list), function(df, nm) {
  if (nm %in% names(signature_variety)) {
    pts <- df %>% 
      filter(variety == signature_variety[[nm]]) %>% 
      pull(points)
    if (length(pts) == 0) pts <- df$points
    pts
  } else {
    df$points
  }
})

# Summary statistics
counts_tbl <- tibble(
  Region = names(Y),
  n = sapply(Y, length),
  Mean = round(sapply(Y, function(x) mean(x, na.rm = TRUE)), 2),
  SD = round(sapply(Y, function(x) sd(x, na.rm = TRUE)), 2)
)

print(counts_tbl)

# ========================================
# 3. EXPLORATORY PLOTS
# ========================================
cat("\n3. Creating exploratory plots...\n")

# Boxplot
p_box <- ggplot(wine_es, aes(x = region_1, y = points, fill = region_1)) +
  geom_boxplot(alpha = 0.7, outlier.shape = 21, outlier.alpha = 0.5) +
  geom_jitter(width = 0.15, alpha = 0.2, size = 0.8) +
  scale_fill_brewer(palette = "Set2") +
  labs(x = "Region", 
       y = "Critic Score",
       title = paste0("Wine Scores by Spanish Region ",
                      "(", if(BUDGET_MODE) "$15-$20" else "All Prices", ")")) +
  theme(legend.position = "none",
        axis.text.x = element_text(angle = 45, hjust = 1))

ggsave(filename = file.path("figs", 
                            paste0("boxplot_", 
                                   if(BUDGET_MODE) "budget" else "all", 
                                   ".png")),
       plot = p_box, width = 8, height = 5, dpi = 160)

cat("  Saved: figs/boxplot_*.png\n")

# ========================================
# 4. FIT BAYESIAN MODEL
# ========================================
cat("\n4. Running Gibbs sampler...\n")

priors <- list(
  mu0 = 88.5,   # Prior mean
  g0sq = 1000,  # Prior variance on mu
  nu0 = 1,      # Prior df for sigma2
  s0 = 10,      # Prior scale for sigma2
  eta0 = 1,     # Prior df for tau2
  t0 = 10       # Prior scale for tau2
)

cat("  Iterations: 5000\n")
cat("  Chains: 1\n")

fit <- gibbs_hier_normal(Y, priors = priors, S = 5000, seed = SEED)

THETA <- fit$THETA
MST   <- fit$MST
post  <- fit$post

cat("  Sampling complete.\n")

# ========================================
# 5. MCMC DIAGNOSTICS
# ========================================
cat("\n5. MCMC diagnostics...\n")

ess <- effectiveSize(MST)
cat("  Effective sample sizes:\n")
cat("    mu:", round(ess[1]), "\n")
cat("    sigma2:", round(ess[2]), "\n") 
cat("    tau2:", round(ess[3]), "\n")

# ========================================
# 6. POSTERIOR INFERENCE
# ========================================
cat("\n6. Posterior inference...\n")

# Region means
post_theta <- apply(THETA, 2, mean)
ci_theta   <- apply(THETA, 2, quantile, probs = c(0.025, 0.5, 0.975)) %>% 
  t() %>% 
  as.data.frame()

ci_theta$region <- rownames(ci_theta)
names(ci_theta) <- c("Lower95", "Median", "Upper95", "Region")

theta_tbl <- ci_theta %>%
  dplyr::select(Region, Lower95, Median, Upper95) %>%
  mutate(across(where(is.numeric), ~round(., 2))) %>%
  arrange(desc(Median))

cat("\nRegion Rankings (95% CI):\n")
print(theta_tbl)

# Save to CSV
write_csv(theta_tbl, 
          file.path("outputs", 
                    paste0("posterior_region_means_",
                           if(BUDGET_MODE) "budget" else "all",
                           ".csv")))

cat("\n  Saved: outputs/posterior_region_means_*.csv\n")

# Forest plot
p_forest <- ggplot(theta_tbl, aes(x = reorder(Region, Median), y = Median)) +
  geom_point(size = 3, color = "darkblue") +
  geom_errorbar(aes(ymin = Lower95, ymax = Upper95), 
                width = 0.2, color = "darkblue", size = 0.8) +
  geom_hline(yintercept = mean(MST[, "mu"]), 
             linetype = "dashed", alpha = 0.5) +
  coord_flip() +
  labs(x = "Region", 
       y = "Posterior Mean Score (95% CI)",
       title = paste0("Region Rankings ",
                      "(", if(BUDGET_MODE) "Budget" else "All Prices", ")"))

ggsave(file.path("figs", 
                 paste0("forest_", 
                        if(BUDGET_MODE) "budget" else "all", 
                        ".png")),
       p_forest, width = 7, height = 5, dpi = 160)

cat("  Saved: figs/forest_*.png\n")

# ========================================
# 7. VARIANCE DECOMPOSITION
# ========================================
cat("\n7. Variance decomposition...\n")

R_post <- post$tau2 / (post$tau2 + post$sigma2)
R_summary <- quantile(R_post, c(0.025, 0.5, 0.975))

cat("  Proportion of variance due to region (R):\n")
cat(sprintf("    Median: %.1f%%\n", 100 * R_summary[2]))
cat(sprintf("    95%% CI: [%.1f%%, %.1f%%]\n", 
            100 * R_summary[1], 100 * R_summary[3]))

# Plot R density
p_R <- data.frame(R = R_post) %>%
  ggplot(aes(x = R)) +
  geom_density(fill = "steelblue", alpha = 0.7) +
  geom_vline(xintercept = R_summary[2], 
             linetype = "dashed", size = 1) +
  scale_x_continuous(labels = scales::percent) +
  labs(x = "Proportion of Variance Due to Region (R)",
       y = "Posterior Density",
       title = "Variance Decomposition")

ggsave(file.path("figs", 
                 paste0("R_density_", 
                        if(BUDGET_MODE) "budget" else "all", 
                        ".png")),
       p_R, width = 6, height = 4, dpi = 160)

cat("  Saved: figs/R_density_*.png\n")

# ========================================
# 8. SUMMARY
# ========================================
cat("\n===============================================\n")
cat("ANALYSIS COMPLETE!\n")
cat("===============================================\n\n")

cat("Key Findings:\n")
cat("  Top region:", theta_tbl$Region[1], 
    "(Mean:", theta_tbl$Median[1], ")\n")
cat("  Regional effect:", sprintf("%.1f%%", 100 * R_summary[2]),
    "of total variance\n")

cat("\nOutputs saved:\n")
cat("  - figs/boxplot_*.png\n")
cat("  - figs/forest_*.png\n")
cat("  - figs/R_density_*.png\n")
cat("  - outputs/posterior_region_means_*.csv\n")

cat("\nTo run with different settings, edit BUDGET_MODE in this script.\n")