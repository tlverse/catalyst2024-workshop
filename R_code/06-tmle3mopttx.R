## ---- align='center', fig.cap="Illustration of a Dynamic Treatment Regime in a Clinical Setting", echo=FALSE, eval=TRUE, out.width='60%'----
knitr::include_graphics(path = "img/png/DynamicA_Illustration.png")


## ----setup-mopttx, message=FALSE, warning=FALSE-------------------------------
library(data.table)
library(sl3)
library(tmle3)
library(tmle3mopttx)
library(devtools)
library(here)
set.seed(111)


## ----load_data_bin, echo=FALSE------------------------------------------------
load(here("data", "tmle3mopttx_bin.RData"))


## ----load sim_bin_data, eval=FALSE, echo=FALSE--------------------------------
## data("data_bin")
## data <- data_bin


## ----load sim_bin_data_head---------------------------------------------------
head(data)


## ----data_nodes2-mopttx-------------------------------------------------------
# organize data and nodes for tmle3
node_list <- list(
  W = c("W1", "W2", "W3"),
  A = "A",
  Y = "Y"
)
node_list


## ----mopttx_sl3_lrnrs2--------------------------------------------------------
# Define sl3 library and metalearners:
lrn_mean  <- Lrnr_mean$new()
lrn_glm   <- Lrnr_glm_fast$new()
lrn_lasso <- Lrnr_glmnet$new()
lrnr_hal  <- Lrnr_hal9001$new(reduce_basis=1/sqrt(nrow(data)) )

## Define the Q learner:
Q_learner <- Lrnr_sl$new(
  learners = list(lrn_lasso, lrn_mean, lrn_glm),
  metalearner = Lrnr_nnls$new()
)

## Define the g learner:
g_learner <- Lrnr_sl$new(
  learners = list(lrn_lasso, lrn_glm),
  metalearner = Lrnr_nnls$new()
)

## Define the B learner:
b_learner <- Lrnr_sl$new(
  learners = list(lrn_mean, lrn_glm, lrn_lasso),
  metalearner = Lrnr_nnls$new()
)


## ----mopttx_make_lrnr_list----------------------------------------------------
# specify outcome and treatment regressions and create learner list
learner_list <- list(Y = Q_learner, A = g_learner, B = b_learner)
learner_list


## ----mopttx_spec_init_complex, eval=FALSE-------------------------------------
## # initialize a tmle specification
## tmle_spec <- tmle3_mopttx_blip_revere(
##   V = c("W1", "W2", "W3"), type = "blip1",
##   learners = learner_list,
##   maximize = TRUE, complex = TRUE,
##   realistic = FALSE, resource = 1,
##   interpret=TRUE
## )


## ----mopttx_fit_tmle_auto_blip_revere_complex, eval=FALSE---------------------
## # fit the TML estimator
## fit <- tmle3(tmle_spec, data, node_list, learner_list)


## ----mopttx_fit_tmle_auto_blip_revere_complex_res, eval=TRUE------------------
# see the result
fit


## ----mopttx_fit_tmle_auto_blip_revere_complex_HAL, eval=TRUE------------------
# Interpretable rule
head(tmle_spec$blip_fit_interpret$coef)


## ----mopttx_fit_tmle_auto_blip_revere_complex_HAL2, eval=TRUE-----------------
# Interpretable rule
head(tmle_spec$blip_fit_interpret$term)


## ----mopttx_spec_init_complex_resource, eval=FALSE----------------------------
## # initialize a tmle specification
## tmle_spec_resource <- tmle3_mopttx_blip_revere(
##   V = c("W1", "W2", "W3"), type = "blip1",
##   learners = learner_list,
##   maximize = TRUE, complex = TRUE,
##   realistic = FALSE, resource = 0.80
## )


## ----mopttx_fit_tmle_auto_blip_revere_complex_resource, eval=FALSE------------
## # fit the TML estimator
## fit_resource <- tmle3(tmle_spec_resource, data, node_list, learner_list)


## ----mopttx_fit_tmle_auto_blip_revere_complex_resource_res, eval=TRUE---------
# see the result
fit_resource


## ----mopttx_compare_resource--------------------------------------------------
# Number of individuals with A=1 (no resource constraint):
table(tmle_spec$return_rule)

# Number of individuals with A=1 (resource constraint):
table(tmle_spec_resource$return_rule)


## ----mopttx_spec_init_complex_V_empty-----------------------------------------
# initialize a tmle specification
tmle_spec_V_empty <- tmle3_mopttx_blip_revere(
  type = "blip1",
  learners = learner_list,
  maximize = TRUE, complex = TRUE,
  realistic = FALSE, resource = 1
)


## ----mopttx_fit_tmle_auto_blip_revere_complex_V_empty, eval=FALSE-------------
## # fit the TML estimator
## fit_V_empty <- tmle3(tmle_spec_V_empty, data, node_list, learner_list)


## ----mopttx_fit_tmle_auto_blip_revere_complex_V_empty_res, eval=TRUE----------
# see the result:
fit_V_empty


## ----load_results, eval=TRUE, echo=FALSE--------------------------------------
load(here("data", "tmle3mopttx_cat.RData"))


## ----load sim_cat_data, eval=FALSE, echo=FALSE--------------------------------
## data("data_cat_realistic")


## ----load sim_cat_data_head, eval=TRUE----------------------------------------
head(data)


## ----data_nodes-mopttx--------------------------------------------------------
# organize data and nodes for tmle3
data <- data_cat_realistic
node_list <- list(
  W = c("W1", "W2", "W3", "W4"),
  A = "A",
  Y = "Y"
)
node_list


## ----data_cats-mopttx---------------------------------------------------------
# organize data and nodes for tmle3
table(data$A)


## ----sl3_lrnrs-mopttx, eval=TRUE----------------------------------------------
# Initialize few of the learners:
lrn_xgboost_50 <- Lrnr_xgboost$new(nrounds = 50)
lrn_mean <- Lrnr_mean$new()
lrn_glm <- Lrnr_glm_fast$new()

## Define the Q learner, which is just a regular learner:
Q_learner <- Lrnr_sl$new(
  learners = list(lrn_xgboost_50, lrn_mean, lrn_glm),
  metalearner = Lrnr_nnls$new()
)

## Define the g learner, which is a multinomial learner:
# specify the appropriate loss of the multinomial learner:
mn_metalearner <- make_learner(Lrnr_solnp,
  eval_function = loss_loglik_multinomial,
  learner_function = metalearner_linear_multinomial
)
g_learner <- make_learner(Lrnr_sl, list(lrn_xgboost_50, lrn_mean), mn_metalearner)

## Define the Blip learner, which is a multivariate learner:
learners <- list(lrn_xgboost_50, lrn_mean, lrn_glm)
b_learner <- create_mv_learners(learners = learners)


## ----cat_learners-------------------------------------------------------------
# See which learners support multi-class classification:
sl3_list_learners(c("categorical"))


## ----make_lrnr_list-mopttx----------------------------------------------------
# specify outcome and treatment regressions and create learner list
learner_list <- list(Y = Q_learner, A = g_learner, B = b_learner)
learner_list


## ----spec_init, eval=FALSE----------------------------------------------------
## # initialize a tmle specification
## tmle_spec_cat <- tmle3_mopttx_blip_revere(
##   V = c("W1", "W2", "W3", "W4"), type = "blip2",
##   learners = learner_list, maximize = TRUE, complex = TRUE,
##   realistic = FALSE
## )


## ----fit_tmle_auto, eval=FALSE------------------------------------------------
## # fit the TML estimator
## fit_cat <- tmle3(tmle_spec_cat, data, node_list, learner_list)


## ----fit_tmle_auto_res, eval=TRUE---------------------------------------------
# see the result:
fit_cat

# How many individuals got assigned each treatment?
table(tmle_spec_cat$return_rule)


## ----mopttx_spec_init_noncomplex, eval=FALSE----------------------------------
## # initialize a tmle specification
## tmle_spec_cat_simple <- tmle3_mopttx_blip_revere(
##   V = c("W4", "W3", "W2", "W1"), type = "blip2",
##   learners = learner_list,
##   maximize = TRUE, complex = FALSE, realistic = FALSE
## )


## ----mopttx_fit_tmle_auto_blip_revere_noncomplex, eval=FALSE------------------
## # fit the TML estimator
## fit_cat_simple <- tmle3(tmle_spec_cat_simple, data, node_list, learner_list)


## ----mopttx_fit_tmle_auto_blip_revere_noncomplex_res, eval=TRUE---------------
# see the result:
fit_cat_simple


## ----mopttx_spec_init_realistic, eval=FALSE-----------------------------------
## # initialize a tmle specification
## tmle_spec_cat_realistic <- tmle3_mopttx_blip_revere(
##   V = c("W4", "W3", "W2", "W1"), type = "blip2",
##   learners = learner_list,
##   maximize = TRUE, complex = TRUE, realistic = TRUE
## )


## ----mopttx_fit_tmle_auto_blip_revere_realistic, eval=FALSE-------------------
## # fit the TML estimator
## fit_cat_realistic <- tmle3(tmle_spec_cat_realistic, data, node_list, learner_list)


## ----mopttx_fit_tmle_auto_blip_revere_realistic_res, eval=TRUE----------------
# see the result:
fit_cat_realistic

# How many individuals got assigned each treatment?
table(tmle_spec_cat_realistic$return_rule)


## ----data_nodes-add-missigness-mopttx, eval=FALSE-----------------------------
## data_missing <- data_cat_realistic
## 
## #Add some random missingless:
## rr <- sample(nrow(data_missing), 100, replace = FALSE)
## data_missing[rr,"Y"]<-NA


## ----data_nodes-add-missigness-mopttx_res, eval=TRUE--------------------------
# look at the data again:
summary(data_missing$Y)


## ----sl3_lrnrs-add-mopttx-----------------------------------------------------
delta_learner <- Lrnr_sl$new(
  learners = list(lrn_mean, lrn_glm),
  metalearner = Lrnr_nnls$new()
)

# specify outcome and treatment regressions and create learner list
learner_list <- list(Y = Q_learner, A = g_learner, B = b_learner, delta_Y=delta_learner)
learner_list


## ----spec_init_missingness, eval=FALSE----------------------------------------
## # initialize a tmle specification
## tmle_spec_cat_miss <- tmle3_mopttx_blip_revere(
##   V = c("W1", "W2", "W3", "W4"), type = "blip2",
##   learners = learner_list, maximize = TRUE, complex = TRUE,
##   realistic = FALSE
## )


## ----fit_tmle_auto2, eval=FALSE-----------------------------------------------
## # fit the TML estimator
## fit_cat_miss <- tmle3(tmle_spec_cat_miss, data_missing, node_list, learner_list)


## ----fit_tmle_auto2_res, eval=TRUE--------------------------------------------
fit_cat_miss


## ----data_vim-nodes-mopttx----------------------------------------------------
# bin baseline covariates to 3 categories:
data$W1<-ifelse(data$W1<quantile(data$W1)[2],1,ifelse(data$W1<quantile(data$W1)[3],2,3))

node_list <- list(
  W = c("W3", "W4", "W2"),
  A = c("W1", "A"),
  Y = "Y"
)
node_list


## ----mopttx_spec_init_vim, eval=FALSE-----------------------------------------
## # initialize a tmle specification
## tmle_spec_vim <- tmle3_mopttx_vim(
##   V=c("W2"),
##   type = "blip2",
##   learners = learner_list,
##   maximize = FALSE,
##   method = "SL",
##   complex = TRUE,
##   realistic = FALSE
## )
## 
## # fit the TML estimator
## vim_results <- tmle3_vim(tmle_spec_vim, data, node_list, learner_list,
##   adjust_for_other_A = TRUE
## )


## ----mopttx_fit_tmle_auto_vim, eval=TRUE--------------------------------------
# see results:
print(vim_results)


## ----load-washb-data, message=FALSE, warning=FALSE, cache=FALSE, eval=FALSE----
## washb_data <- fread("https://raw.githubusercontent.com/tlverse/tlverse-data/master/wash-benefits/washb_data.csv", stringsAsFactors = TRUE)
## washb_data <- washb_data[!is.na(momage), lapply(.SD, as.numeric)]
## head(washb_data, 3)


## ----washb-data-npsem-mopttx, message=FALSE, warning=FALSE, cache=FALSE, eval=FALSE----
## node_list <- list(W = names(washb_data)[!(names(washb_data) %in% c("whz", "tr", "momheight"))],
##                   A = "tr", Y = "whz")


## ----summary_WASH, eval=FALSE-------------------------------------------------
## #V1, V2 and V3:
## table(washb_data$momedu)
## table(washb_data$floor)
## table(washb_data$asset_refrig)
## 
## #A:
## table(washb_data$tr)
## 
## #Y:
## summary(washb_data$whz)


## ----sl3_lrnrs-WASH-mopttx, eval=FALSE----------------------------------------
## # Initialize few of the learners:
## grid_params = list(nrounds = c(100, 500),
##                      eta = c(0.01, 0.1))
## grid = expand.grid(grid_params, KEEP.OUT.ATTRS = FALSE)
## xgb_learners = apply(grid, MARGIN = 1, function(params_tune) {
##     do.call(Lrnr_xgboost$new, c(as.list(params_tune)))
##   })
## lrn_mean <- Lrnr_mean$new()
## 
## ## Define the Q learner, which is just a regular learner:
## Q_learner <- Lrnr_sl$new(
##   learners = list(xgb_learners[[1]], xgb_learners[[2]], xgb_learners[[3]],
##                   xgb_learners[[4]], lrn_mean),
##   metalearner = Lrnr_nnls$new()
## )
## 
## ## Define the g learner, which is a multinomial learner:
## #specify the appropriate loss of the multinomial learner:
## mn_metalearner <- make_learner(Lrnr_solnp, loss_function = loss_loglik_multinomial,
##                                learner_function = metalearner_linear_multinomial)
## g_learner <- make_learner(Lrnr_sl, list(xgb_learners[[4]], lrn_mean), mn_metalearner)
## 
## ## Define the Blip learner, which is a multivariate learner:
## learners <- list(xgb_learners[[1]], xgb_learners[[2]], xgb_learners[[3]],
##                   xgb_learners[[4]], lrn_mean)
## b_learner <- create_mv_learners(learners = learners)
## 
## learner_list <- list(Y = Q_learner, A = g_learner, B = b_learner)


## ----spec_init_WASH, eval=FALSE-----------------------------------------------
## ## Question 2:
## 
## #Initialize a tmle specification
## tmle_spec_Q <- tmle3_mopttx_blip_revere(
##   V = c("momedu", "floor", "asset_refrig"), type = "blip2",
##   learners = learner_list, maximize = TRUE, complex = TRUE,
##   realistic = FALSE
## )
## 
## #Fit the TML estimator.
## fit_Q <- tmle3(tmle_spec_Q, data=washb_data, node_list, learner_list)
## fit_Q
## 
## #Which intervention is the most dominant?
## table(tmle_spec_Q$return_rule)


## ----spec_init_WASH_simple_q3, eval=FALSE-------------------------------------
## ## Question 3:
## 
## #Initialize a tmle specification with "realistic=TRUE":
## tmle_spec_Q_realistic <- tmle3_mopttx_blip_revere(
##   V = c("momedu", "floor", "asset_refrig"), type = "blip2",
##   learners = learner_list, maximize = TRUE, complex = TRUE,
##   realistic = TRUE
## )
## 
## #Fit the TML estimator.
## fit_Q_realistic <- tmle3(tmle_spec_Q_realistic, data=washb_data, node_list, learner_list)
## fit_Q_realistic
## 
## table(tmle_spec_Q_realistic$return_rule)

