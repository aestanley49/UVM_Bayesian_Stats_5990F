# Code to set up a basic linear regression in Stan
library(rstan)
library(MCMCvis)
library(shinystan)

### Create Data (Fake!) ####
# Create some data where we know the exact relationships between variables
aa <- -0.25 # Alpha, our intercept
bb <- 0.75 # Beta, our slope
ss <- 3.2 # Sigma, our error

# Create independent variable, X, from uniform distribution
xx <- runif(100,-10,10)

# Create dependent variable, Y with both deterministic part and normal-distributed random error
yy <- aa + bb * xx + rnorm(length(xx),0,ss) 

## TODO 1) Plot xx, yy as a scatter plot. Add some color to make it look nice.


### Prepare Data for Stan ####
input_data <- list(
  N = length(xx),
  xx = xx,
  yy = yy
)

#TODO 2) Before running, take a look at the associated Stan file.

### Run Stan model ####
stan_model <- stan(
  file = "Stan_models/S1_LinearRegression.stan",  # Stan program
  data = input_data,    # named list of data
  chains = 4,             # number of Markov chains
  warmup = 1000,          # number of warmup iterations per chain
  iter = 2000,            # total number of iterations per chain
  cores = 4             # number of cores (should use one per chain)
)

### Analyze output ####
MCMCsummary(stan_model,pg0 = TRUE)

### Also run a frequentist version just for kicks ####
glm1 <- glm(yy~xx)
summary(glm1)
