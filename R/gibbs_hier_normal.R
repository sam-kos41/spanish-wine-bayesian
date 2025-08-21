#' Gibbs sampler for a normal-normal hierarchical model
#'
#' y_{ij} ~ N(theta_j, sigma^2)
#' theta_j ~ N(mu, tau^2)
#' Priors:  mu ~ N(mu0, g0^2);
#'          sigma^2 ~ Inv-Gamma(nu0/2, (nu0 * s0^2)/2);
#'          tau^2   ~ Inv-Gamma(eta0/2, (eta0 * t0^2)/2)
#'
#' @param Y list of numeric vectors, one per group/region
#' @param priors list(mu0, g0sq, nu0, s0, eta0, t0)
#' @param S integer, number of MCMC draws (default 5000)
#' @param seed integer or NULL
#' @return list(THETA, MST, post = list(mu = ..., sigma2 = ..., tau2 = ...))
#' @export
gibbs_hier_normal <- function(Y,
                              priors = list(mu0 = 88.5, g0sq = 1000,
                                            nu0 = 1, s0 = 10,
                                            eta0 = 1, t0 = 10),
                              S = 5000,
                              seed = NULL) {
  stopifnot(is.list(Y), length(Y) >= 2)
  if (!is.null(seed)) set.seed(seed)

  mu0  <- priors$mu0
  g0sq <- priors$g0sq
  nu0  <- priors$nu0
  s0   <- priors$s0
  eta0 <- priors$eta0
  t0   <- priors$t0

  m    <- length(Y)
  n    <- sapply(Y, function(x) sum(is.finite(x)))
  ybar <- sapply(Y, function(x) mean(x, na.rm = TRUE))
  sv   <- sapply(Y, function(x) var(x, na.rm = TRUE))

  # Starting values
  theta  <- ybar
  sigma2 <- mean(sv[is.finite(sv)], na.rm = TRUE)
  mu     <- mean(theta)
  tau2   <- var(theta)

  THETA <- matrix(NA_real_, nrow = S, ncol = m,
                  dimnames = list(NULL, names(Y)))
  MST   <- matrix(NA_real_, nrow = S, ncol = 3,
                  dimnames = list(NULL, c("mu", "sigma2", "tau2")))

  for (s in seq_len(S)) {
    # theta_j | rest
    for (j in seq_len(m)) {
      vtheta <- 1 / (n[j] / sigma2 + 1 / tau2)
      etheta <- vtheta * (ybar[j] * n[j] / sigma2 + mu / tau2)
      theta[j] <- stats::rnorm(1, etheta, sqrt(vtheta))
    }

    # sigma2 | rest
    ss <- nu0 * s0^2
    for (j in seq_len(m)) {
      ss <- ss + sum((Y[[j]] - theta[j])^2, na.rm = TRUE)
    }
    sigma2 <- 1 / stats::rgamma(1, shape = (nu0 + sum(n)) / 2, rate = ss / 2)

    # mu | rest
    vmu <- 1 / (m / tau2 + 1 / g0sq)
    emu <- vmu * (m * mean(theta) / tau2 + mu0 / g0sq)
    mu  <- stats::rnorm(1, emu, sqrt(vmu))

    # tau2 | rest
    ss_tau <- eta0 * t0^2 + sum((theta - mu)^2)
    tau2   <- 1 / stats::rgamma(1, shape = (eta0 + m) / 2, rate = ss_tau / 2)

    THETA[s, ] <- theta
    MST[s, ]   <- c(mu, sigma2, tau2)
  }

  list(
    THETA = THETA,
    MST = MST,
    post = list(mu = MST[, "mu"], sigma2 = MST[, "sigma2"], tau2 = MST[, "tau2"])
  )
}