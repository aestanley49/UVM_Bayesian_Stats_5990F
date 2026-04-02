# 5 - Hierarchical Models

library(cmdstanr)
library(MCMCvis)
library(shinystan)
library(dplyr)

### Introduction ####

#' Today we are going to expand on the worksheet from last class using the same dataset.
#' Our goal is going to be to include multiple species in a single model.

# Read in our dataset. Data adapted from: https://github.com/bentonelli/Nonstationarity_pheno_climate

spring_arrivals <- readRDS("data/spring_arrivals.rds")

#' As a reminder, our dataset consists of estimated arrival dates, represented as ordinal dates 
#' (1 = Jan. 1, 2= Jan. 2, etc.)
#' 
#' Note that these are estimated arrival dates, so they end up being numbers with decimals.
#' 
#' Our dataset has 12 species, each with arrival dates from different areas (represented numerically)

# Look at how many data points each species has
table(spring_arrivals$species) 

head(spring_arrivals)
spring_arrivals$sp_num <- as.numeric(as.factor(spring_arrivals$species))

sp_ar_ind <- spring_arrivals %>% 
  select(sp_num,species,area) %>%
  unique()

sp_ar_ind$sp_ar <- 1:nrow(sp_ar_ind)

spring_arrivals <- merge(sp_ar_ind,spring_arrivals,by=c("species","area"))

spring_arrivals$std_year <- spring_arrivals$year-min(spring_arrivals$year)

#Take a look at the new data
head(spring_arrivals)
nrow(spring_arrivals)

### Prepare data ####
input_data <- list(
  N = nrow(spring_arrivals),
  yy = spring_arrivals$arr_est,
  year = spring_arrivals$std_year,
  
  N_sp_areas = length(unique(spring_arrivals$sp_ar)),
  sp_ar = as.numeric(spring_arrivals$sp_ar),
  
  N_sp = length(unique(sp_ar_ind$sp_num)),
  sp = sp_ar_ind$sp_num
)

### In-class to-dos ####
#' TODO(1): Read over the data block, and the relevant stan file. Discuss with a
#' neighbor: how many alphas are now being estimated? How many betas? What do these represent?
#' Add your answer below.
#' 
#' TODO(2): The alphas and betas are drawn from their own distributions. 
#' How many mu_alphas and mu_betas are there? What do these represent?
#' Add your answer below.
#' 
#' TODO(3): Run the model, then plot out the omega, and mu_betas using the MCMCplot function. 
#' Screenshot or take a picture of this plot and save it locally.
#' What is the biological takeaway from these plots? Are birds changing when they
#' are arriving at their breeding grounds over time?
#' Add your answer below.

### Homework to-dos ####
#' Bayesian hierarchical models allow us to do pretty cool things. The next two 
#' todos will have you explore two of these options

#' TODO(4): We can incorporate measurement error into Bayesian hierarchical models.
#' In our case, each arrival date estimate (arr_est) comes with an error value (arr_est_err) that 
#' represents the uncertainty of that estimate (measured as the standard deviation).
#' We can incorporate this uncertainty with a couple additional lines of code.
#' 
#' Step A) In the data list above, add a new line where yy_unc = the data in the arr_est_err column. 
#' Then add this incoming data to your data block in the stan model.
#' 
#' Step B) On the first line of your parameters block, add a new vector called yy_true
#' of length N that represents the true (unknown) arrival date.
#' 
#' Step C) In the model block add a new line just above the final model line code:
#' yy ~ normal(yy_true,yy_unc); This tells your model that the estimated arrival dates
#' are a function of the true arrival date and the measured uncertainty
#' 
#' Step D) Change your final model line code (yy~ normal(alpha...)), replacing "yy" with "yy_true".
#' 
#' Does incorporating this uncertainty change the omega and mu_beta estimates?
#' 
#' TODO(5) OPTIONAL! It can be helpful to estimate sigmas at the group level 
#' (i.e. species), although getting the model to fit this way
#' can sometimes be difficult. Change your model so that you have one sigma for each
#' species. Those sigmas should be drawn from a new distribution. Remember, sigmas should be
#' positive only. If you choose to do this step, let me know how it went below!

### Run model ####

# CHANGE
mod <- cmdstan_model("Stan_models/S6_HierarchicalModels_theSequel.stan")

stan_model <- mod$sample(
  data = input_data,
  iter_warmup = 2000,
  iter_sampling = 3000,
  adapt_delta = .8,
  chains = 4,
  parallel_chains = 4,
  refresh = 500 
)

MCMCsummary(stan_model)


