# Spanish Wine Regions — Bayesian Hierarchical Analysis

![R](https://img.shields.io/badge/R-4.3%2B-blue?logo=r)
![License](https://img.shields.io/badge/License-MIT-green)
![Analysis](https://img.shields.io/badge/Analysis-Bayesian%20MCMC-purple)
[![Check Analysis](https://github.com/sam-kos41/spanish-wine-bayesian/workflows/Check%20Analysis/badge.svg)](https://github.com/sam-kos41/spanish-wine-bayesian/actions)

A statistical comparison of critic scores across five major Spanish wine regions using Bayesian hierarchical modeling and MCMC methods.

## 🎯 Project Overview

This project demonstrates advanced statistical modeling techniques applied to real-world wine rating data. Using a custom Gibbs sampler implementation, we compare wine quality across Spanish regions while accounting for both within-region and between-region variation.

### Key Features

- **Bayesian Hierarchical Modeling**: Properly accounts for nested data structure (wines within regions)
- **Custom MCMC Implementation**: Hand-coded Gibbs sampler with full diagnostics
- **Two Analysis Modes**: 
  - Budget wines ($15-$20) for value comparison
  - All prices for overall quality assessment
- **Professional Visualization**: Publication-ready plots with uncertainty quantification
- **Reproducible Research**: Parameterized R Markdown with automated output generation

## 📊 Statistical Methods

### Model Specification

```
y_ij | θ_j, σ² ~ N(θ_j, σ²)     # Wine scores within region j
θ_j | μ, τ² ~ N(μ, τ²)          # Region effects
```

With weakly informative priors on hyperparameters.

### Key Outputs

- **Region Rankings**: Posterior means with 95% credible intervals
- **Variance Decomposition**: Proportion of variance attributable to region vs. individual bottles
- **MCMC Diagnostics**: Trace plots, ACF, effective sample sizes

## 🗂 Repository Structure

```
Bayesian R code/
├── R/
│   └── gibbs_hier_normal.R       # Reusable Gibbs sampler function
├── data/
│   └── winemag-data-130k-v2.csv  # Wine dataset (user must add)
├── figs/                          # Auto-generated plots
├── outputs/                       # Auto-generated tables (CSV)
├── spanish-wines-bayesian.Rmd    # Main analysis document
└── README.md                      # This file
```

## 🚀 Getting Started

### Prerequisites

```r
# Required R packages
install.packages(c("dplyr", "ggplot2", "readr", 
                   "tidyr", "purrr", "coda", 
                   "knitr", "rmarkdown"))
```

### Data Setup

1. Download the Wine Reviews dataset from [Kaggle](https://www.kaggle.com/zynicide/wine-reviews)
2. Place `winemag-data-130k-v2.csv` in the `data/` folder

### Running the Analysis

```r
# Budget wines analysis ($15-$20)
rmarkdown::render('spanish-wines-bayesian.Rmd', 
                  params = list(budget_mode = TRUE, seed = 1))

# All prices analysis
rmarkdown::render('spanish-wines-bayesian.Rmd', 
                  params = list(budget_mode = FALSE, seed = 1))
```

## 📈 Sample Results

The analysis produces:

- **Forest plots** comparing region means with uncertainty
- **Density plots** of posterior distributions
- **Variance decomposition** showing regional effects
- **CSV tables** of posterior summaries

All outputs are automatically saved to `figs/` and `outputs/` directories.

## 🔧 Technical Highlights

### Custom Gibbs Sampler (`R/gibbs_hier_normal.R`)

- Fully vectorized for efficiency
- Proper handling of missing data
- Returns both raw MCMC chains and summary statistics
- Modular design for reuse in other projects

### Analysis Features

- **Signature Varieties**: Analysis focuses on characteristic wines for each region
  - Rioja → Tempranillo Blend
  - Jerez → Sherry
  - Ribera del Duero → Tempranillo
  - Rias-Baixas → Albariño
  
- **MCMC Diagnostics**: Full convergence assessment including effective sample sizes and autocorrelation

## 📚 Skills Demonstrated

- **Statistical Modeling**: Hierarchical Bayesian models, MCMC methods
- **R Programming**: Custom functions, tidyverse, functional programming with `purrr`
- **Data Visualization**: ggplot2 with publication-quality plots
- **Reproducible Research**: Parameterized R Markdown, automated workflows
- **Software Engineering**: Modular code structure, clear documentation

## 🤝 Contributing

Feel free to open issues or submit pull requests with improvements.

## 📄 License

This project is open source and available under the MIT License.

## 👤 Author

**Sam Koscelny**  
Statistical Analysis | Data Science | Bayesian Methods

---

*Note: This project was originally developed as part of STAT 5213 coursework and has been refactored for portfolio presentation.*