# In this code exercise, you'll be "choosing your own adventure!"

# We will be using a REAL (*gasp*) dataset of small mammal Lyme disease (Borrelia) surveillance

### Install CmdStan ####
# If you have issues: https://mc-stan.org/cmdstanr/articles/cmdstanr.html
install.packages("cmdstanr", repos = c('https://stan-dev.r-universe.dev', getOption("repos")))

library(MCMCvis)
library(cmdstanr)
library(shinystan)

install_cmdstan()

#Import the data
lyme_data <- read.csv("data/Mammal_Lyme.csv")

#Check it out
head(lyme_data)

# There's a site name, lat-long location, and other info in there.

# Testing effort varies, with the total number of animals tested reported

# The total number of animals that tested positive is in there

# And finally, there is a column of zeros and ones indicating whether Borrelia was
# detected at least once in that location, year, and month.

### OBJECTIVES ####
# Today, you are going to design your own analysis. We are interested in what 
# explains whether borrelia is detected at a site in a given month.

# TODO 1) Take a look at the code below, and in the affiliated stan file. Then,
# write out a set of equations ON PAPER that describe the model as it currently exists.
# Check your equation with a classmate, then with Ben.

# TODO 2) Next, add a new variable (you may choose to call in xx2 for consistency)
# to your model equation. Then add this variable, and an associated coefficient to the data
# block, the model code, and the MCMCsummary line below. Make sure to set a prior for the new coefficient

# TODO 3) Run your new model. Below, write down what your results mean in general terms. If you have extra time

### Prepare Data for Stan ####
input_data <- list(
  N = nrow(lyme_data),
  yy = lyme_data$borrelia_detected,
  xx1 = lyme_data$total_tested
)

mod <- cmdstan_model("Stan_models/S3_LogisticRegression.stan")

### Run Stan model ####
stan_model <- mod$sample(
  data = input_data,
  iter_warmup = 2000,
  iter_sampling = 2000,
  chains = 4,
  parallel_chains = 4,
  refresh = 500 
)

MCMCsummary(stan_model,params=c("alpha","beta1"),pg0 = TRUE)
