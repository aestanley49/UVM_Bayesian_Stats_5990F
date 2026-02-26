# In this code exercise, you'll be "choosing your own adventure!"

# We will be using a REAL (*gasp*) dataset of small mammal Lyme disease (Borrelia) surveillance

library(MCMCvis)
library(rstan)
library(shinystan)

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

### Run Stan model ####
stan_model <- stan(
  file = "Stan_models/S3_LogisticRegression.stan",  # Stan program
  data = input_data,    # named list of data
  chains = 4,             # number of Markov chains
  warmup = 2000,          # number of warmup iterations per chain
  iter = 4000,            # total number of iterations per chain
  cores = 4             # number of cores (should use one per chain)
)

MCMCsummary(stan_model,params=c("alpha","beta1"),pg0 = TRUE)
