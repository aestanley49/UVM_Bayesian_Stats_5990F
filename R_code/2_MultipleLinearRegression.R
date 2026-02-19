# Code to set up a multiple linear regression in Stan
# This code needs to be adapted to augment a basic linear regression model.

# We'll add a new parameter, theta, to our model
# Theta will describe the effect of a binary variable on our dependent variable

library(rstan)
library(MCMCvis)
library(shinystan)

### Example - Mangrove Leaf Area Index (LAI) post-disturbance ####
# Inspired by: https://onlinelibrary.wiley.com/doi/10.1111/gcb.70124

# Mangrove forests are critical ecosystems but are routinely impacted by hurricanes.
# When hurricanes hit, defoliation occurs, lowering the "leaf area index" - a measure of canopy coverage 
# Here, we are interested in how leaf area declines in the year following hurricanes. 
# We will also measure and account for the effect of canopy height on LAI

### Create Data (Fake!) ####

# Create some data where we know the exact relationships between variables

# Our data will represent Leaf Area Index measurements populations in Everglades National Park, FL

### Parameters
aa <- 7.5 # Alpha - This will represent the average LAI in non-disturbed areas with mean canopy height
bb <- 0.5 # Beta - This will represent the effect of canopy height on LAI 
ss <- 1.2 # Sigma - Error, or process variance

# TODO (1) Add a new parameter here called "tt" (theta) and set it's value to -2.5 
# Theta represents the effect on LAI of a hurricane occurring in the past year.


### Variables

# "ch" will represent canopy height, measure in meters
ch <- runif(200,10,15) # Independent variable, ch

# We will standardize our canopy height data by subtracting the mean. This will aid
# in interpretation of the intercept parameter (see above)
ch_s <- ch - mean(ch)

# Simulate some new fake data for a new independent variable called "hh" (hurricane, yes or no)
# Zeros mean no hurricane in the last year, 
# Ones mean there was a hurricane in the last year.
hh <- sample(c(0,0,0,0,1),200,replace=TRUE)

# TODO (2) Augment the code below, adding tt * hh into the equation
lai <- aa + bb * ch_s + rnorm(length(hh),0,ss) # Create dependent variable, LAI

# Think for a second about how this will work...
# When hh = 0 (no hurricane), tt * hh = 0. When hh = 1, tt * hh = tt

# So theta only gets "activated" when a datapoint is in the hurricane group (hh=0)

plot(ch_s,lai,pch=19) # Plot to see relationship between 1st variable (xx1) and y 
boxplot(lai~hh) # Plot to see relationship between 2nd variable (hh) and y 

#Let's combine this into one dataframe, and visualize
our_data <- data.frame(lai=lai,ch_s=ch_s,hh=hh)
head(our_data)

### Prepare Data for Stan ####
input_data <- list(
  N = nrow(our_data),
  ch_s = our_data$ch_s,
  # TODO (3) Add hh in here

  lai = our_data$lai
)

### Run Stan model ####
# TODO (4) Head over to the stan code and follow the instructions there!

stan_model <- stan(
  file = "Stan_models/s_mlr_test.stan",  # Stan program
  data = input_data,    # named list of data
  chains = 4,             # number of Markov chains
  warmup = 2000,          # number of warmup iterations per chain
  iter = 4000,            # total number of iterations per chain
  cores = 4             # number of cores (should use one per chain)
)

### Analyze output ####
MCMCsummary(stan_model,pg0 = TRUE)
launch_shinystan(stan_model)

### Also run a frequentist version for kicks ####
glm1 <- glm(lai~ch_s+hh)
summary(glm1)
