# Required R packages for Spanish Wine Bayesian Analysis
# Run this script to install all dependencies

# Core packages
required_packages <- c(
  "dplyr",      # Data manipulation
  "ggplot2",    # Visualization
  "readr",      # CSV reading
  "tidyr",      # Data tidying
  "purrr",      # Functional programming
  "coda",       # MCMC diagnostics
  "knitr",      # Dynamic reporting
  "rmarkdown"   # R Markdown documents
)

# Check and install missing packages
install_if_missing <- function(packages) {
  missing <- packages[!(packages %in% installed.packages()[,"Package"])]
  if(length(missing) > 0) {
    message("Installing missing packages: ", paste(missing, collapse = ", "))
    install.packages(missing, dependencies = TRUE)
  } else {
    message("All required packages are already installed!")
  }
}

# Install packages
install_if_missing(required_packages)

# Verify installation
loaded <- sapply(required_packages, require, character.only = TRUE, quietly = TRUE)
if(all(loaded)) {
  message("\n✓ All packages successfully installed and loaded!")
  message("You can now run the analysis with:")
  message("  rmarkdown::render('spanish-wines-bayesian.Rmd')")
} else {
  failed <- required_packages[!loaded]
  warning("Failed to load: ", paste(failed, collapse = ", "))
}