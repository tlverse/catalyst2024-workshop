## ---- fig.cap="Animation of how a counterfactual outcome changes as the natural treatment distribution is subjected to a simple stochastic intervention", results = "asis", echo=FALSE----
knitr::include_graphics(path = "img/gif/shift_animation.gif")


## ----setup-shift--------------------------------------------------------------
library(tidyverse)
library(data.table)
library(sl3)
library(tmle3)
library(tmle3shift)
set.seed(429153)


## ----sl3_lrnrs-Qfit-shift-----------------------------------------------------
# learners used for conditional expectation regression
mean_learner <- Lrnr_mean$new()
fglm_learner <- Lrnr_glm_fast$new()
xgb_learner <- Lrnr_xgboost$new(nrounds = 200)
sl_regression_learner <- Lrnr_sl$new(
  learners = list(mean_learner, fglm_learner, xgb_learner)
)


## ----sl3_density_lrnrs_search-shift, message=FALSE, warning=FALSE-------------
sl3_list_learners("density")


## ----sl3_lrnrs-gfit-shift-----------------------------------------------------
# learners used for conditional densities (i.e., generalized propensity score)
haldensify_learner <- Lrnr_haldensify$new(
  n_bins = c(3, 5),
  lambda_seq = exp(seq(-1, -10, length = 200))
)
# semiparametric density estimator based on homoscedastic errors (HOSE)
hose_learner_xgb <- make_learner(Lrnr_density_semiparametric,
  mean_learner = xgb_learner
)
# semiparametric density estimator based on heteroscedastic errors (HESE)
hese_learner_xgb_fglm <- make_learner(Lrnr_density_semiparametric,
  mean_learner = xgb_learner,
  var_learner = fglm_learner
)
# SL for the conditional treatment density
sl_density_learner <- Lrnr_sl$new(
  learners = list(haldensify_learner, hose_learner_xgb,
                  hese_learner_xgb_fglm),
  metalearner = Lrnr_solnp_density$new()
)


## ----learner-list-shift-------------------------------------------------------
Q_learner <- sl_regression_learner
g_learner <- sl_density_learner
learner_list <- list(Y = Q_learner, A = g_learner)


## ----sim_data-----------------------------------------------------------------
# simulate simple data for tmle-shift sketch
n_obs <- 1000 # number of observations
tx_mult <- 2 # multiplier for the effect of W = 1 on the treatment

## baseline covariates -- simple, binary
W <- replicate(2, rbinom(n_obs, 1, 0.5))

## create treatment based on baseline W
A <- rnorm(n_obs, mean = tx_mult * W, sd = 1)

## create outcome as a linear function of A, W + white noise
Y <- rbinom(n_obs, 1, prob = plogis(A + W))

# organize data and nodes for tmle3
data <- data.table(W, A, Y)
setnames(data, c("W1", "W2", "A", "Y"))
node_list <- list(W = c("W1", "W2"), A = "A", Y = "Y")
head(data)


## ----spec_init-shift----------------------------------------------------------
# initialize a tmle specification
tmle_spec <- tmle_shift(
  shift_val = 0.5,
  shift_fxn = shift_additive,
  shift_fxn_inv = shift_additive_inv
)


## ----fit_tmle-shift-----------------------------------------------------------
tmle_fit <- tmle3(tmle_spec, data, node_list, learner_list)
tmle_fit


## ----vim_spec_init------------------------------------------------------------
# what's the grid of shifts we wish to consider?
delta_grid <- seq(from = -1, to = 1, by = 1)

# initialize a tmle specification
tmle_spec <- tmle_vimshift_delta(
  shift_grid = delta_grid,
  max_shifted_ratio = 2
)


## ----fit_tmle_wrapper_vimshift------------------------------------------------
tmle_fit <- tmle3(tmle_spec, data, node_list, learner_list)
tmle_fit


## ----msm_fit------------------------------------------------------------------
tmle_fit$summary[4:5, ]


## ----vim_targeted_msm_fit-----------------------------------------------------
# initialize a tmle specification
tmle_msm_spec <- tmle_vimshift_msm(
  shift_grid = delta_grid,
  max_shifted_ratio = 2
)

# fit the TML estimator and examine the results
tmle_msm_fit <- tmle3(tmle_msm_spec, data, node_list, learner_list)
tmle_msm_fit


## ----load-washb-data-shift----------------------------------------------------
washb_data <- fread("https://raw.githubusercontent.com/tlverse/tlverse-data/master/wash-benefits/washb_data_subset.csv", stringsAsFactors = TRUE)
washb_data <- washb_data[!is.na(momage) & !is.na(momheight), ]
head(washb_data, 3)


## ----washb-data-npsem-shift---------------------------------------------------
node_list <- list(
  W = names(washb_data)[!(names(washb_data) %in%
    c("whz", "momage"))],
  A = "momage", Y = "whz"
)


## ----shift_spec_init_washb----------------------------------------------------
# initialize a tmle specification for just a single delta shift
washb_shift_spec <- tmle_shift(
  shift_val = 2,
  shift_fxn = shift_additive,
  shift_fxn_inv = shift_additive_inv
)


## ----shift_spec_emm_washb-----------------------------------------------------
# initialize effect modification specification around previous specification
washb_shift_strat_spec <-  tmle_stratified(washb_shift_spec)


## ----sl3_lrnrs-gfit-shift-washb-----------------------------------------------
# learners used for conditional density regression (i.e., propensity score),
# but we need to turn on cross-validation for this conditional density learner
hose_learner_xgb_cv <- Lrnr_cv$new(
  learner = hose_learner_xgb,
  full_fit = TRUE
)

# modify learner list, using existing SL for Q fit
learner_list <- list(Y = Q_learner, A = hose_learner_xgb_cv)


## ----fit_shift_emm_washb------------------------------------------------------
# fit stratified TMLE
strat_node_list <- copy(node_list)
strat_node_list$W <- setdiff(strat_node_list$W,"momedu")
strat_node_list$V <- "momedu"
washb_shift_strat_fit <- tmle3(washb_shift_strat_spec, washb_data, strat_node_list,
                               learner_list)
washb_shift_strat_fit


## ----vim_spec_init_washb------------------------------------------------------
# initialize a tmle specification for the variable importance parameter
washb_vim_spec <- tmle_vimshift_delta(
  shift_grid = seq(from = -2, to = 2, by = 1),
  max_shifted_ratio = 2
)


## ----fit_tmle_wrapper_washb---------------------------------------------------
washb_tmle_fit <- tmle3(washb_vim_spec, washb_data, node_list, learner_list)
washb_tmle_fit

