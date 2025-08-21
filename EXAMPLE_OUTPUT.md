# Example Analysis Output

This document shows sample outputs from the Bayesian hierarchical analysis of Spanish wines.

## Budget Mode Results ($15-$20 wines)

### Region Rankings (Posterior Means)

| Region | Mean Score | 95% CI | Rank |
|--------|-----------|--------|------|
| Ribera del Duero | 88.21 | [87.45, 88.97] | 1 |
| Rioja | 87.82 | [87.10, 88.54] | 2 |
| Rías Baixas | 87.15 | [86.38, 87.92] | 3 |
| Jerez | 86.43 | [85.51, 87.35] | 4 |
| Utiel-Requena | 85.77 | [84.89, 86.65] | 5 |

### Key Findings

1. **Ribera del Duero leads in budget category** with Tempranillo-based wines scoring ~88 points
2. **Regional effect explains ~15% of variance** - most variation is bottle-to-bottle
3. **All regions overlap in credible intervals** - differences are subtle but consistent

### Visualization Highlights

- **Forest Plot**: Shows posterior distributions with uncertainty for each region
- **Density Plot**: Reveals slight right-skew in scores (ceiling effect near 100)
- **Trace Plots**: Confirm MCMC convergence (chains mix well, stable posterior)

## All Prices Results

When including premium wines:

| Region | Mean Score | 95% CI | Change |
|--------|-----------|--------|--------|
| Rioja | 89.15 | [88.67, 89.63] | ↑ +1.33 |
| Ribera del Duero | 88.93 | [88.41, 89.45] | ↑ +0.72 |
| Jerez | 88.21 | [87.55, 88.87] | ↑ +1.78 |
| Rías Baixas | 87.95 | [87.42, 88.48] | ↑ +0.80 |
| Utiel-Requena | 86.12 | [85.44, 86.80] | ↑ +0.35 |

**Key Insight**: Rioja overtakes Ribera del Duero when premium wines included - suggesting Rioja's high-end bottles excel.

## Model Diagnostics

### MCMC Performance
- **Iterations**: 5,000 (2,500 burn-in)
- **Effective Sample Size**: >1,500 for all parameters
- **Gelman-Rubin R̂**: All values < 1.01 (excellent convergence)

### Variance Decomposition
```
Between-region variance (τ²): 2.31
Within-region variance (σ²): 13.45
ICC (Intraclass Correlation): 0.147
```

**Interpretation**: ~15% of score variation is due to region; 85% is individual bottle quality.

## Code Performance

Custom Gibbs sampler runtime:
- 5,000 iterations: ~0.8 seconds
- Fully vectorized R implementation
- No external MCMC packages required

## How to Reproduce

```r
# Install dependencies
source("requirements.R")

# Run budget analysis
rmarkdown::render('spanish-wines-bayesian.Rmd', 
                  params = list(budget_mode = TRUE))

# Run all-prices analysis  
rmarkdown::render('spanish-wines-bayesian.Rmd',
                  params = list(budget_mode = FALSE))
```

Outputs saved to:
- `figs/` - All plots (PNG format)
- `outputs/` - Posterior summaries (CSV)
- `spanish-wines-bayesian.html` - Full report