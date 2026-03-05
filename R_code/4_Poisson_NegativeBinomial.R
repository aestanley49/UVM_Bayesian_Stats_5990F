### INTRO ####

# This week, we will be using Poisson and Negative Binomial distributions to model 
# count data. 

### Install cmdstanr ####
# TODO (0) If you didn't do this lat week, install cmdstanr, by uncommenting the next line

#install.packages("cmdstanr", repos = c('https://stan-dev.r-universe.dev', getOption("repos")))

#If you have issues: https://mc-stan.org/cmdstanr/articles/cmdstanr.html

library(cmdstanr)
library(MCMCvis)
library(shinystan)
library(ggplot2)


# TODO (0) uncomment the next line if installing cmdstanr for the first time.
#install_cmdstan()

### Import Data ####
# We will be using real data again this week, from a study on island biodiversity
# within the Lake of the Woods Conservation REserve in Ontario

# Paper here: https://doi.org/10.1111/jbi.13460

# Specifically, we are going to look at how the size of islands predicts the 
# number of vascular plant species on that island.

island_plants <- read.csv("data/island_diversity.csv")

# Set up to view multiple plots at once
par(mfrow=c(2,2)) # 2x2 grid
par(pty="s") #Square plots

#Let's see what the distribution of plant richness looks like:
hist(island_plants$plant_rich,xlab="Richness",main="",col="skyblue")
plot(density(island_plants$plant_rich),xlab="Richness",main="",col="skyblue")
summary(island_plants$plant_rich)

#Let's also look at the main variable of interest, area size
hist(island_plants$area_m2,xlab="Richness",main="",col="orchid4")
plot(density(island_plants$area_m2),xlab="Richness",main="",col="orchid4")
summary(island_plants$area_m2)

# TODO(1): Stop for a second and think about what the histogram and density plots are showing.
# Are they demonstrating the same thing?

# TODO(2): The area of the islands is measured in meters-squared. That leads to some big values!
# Using the data in this "area" column, create a new column called "hectare_area" by
# multiplying the area column by 0.0001 (the conversion from meters-squared to hectares)
# This will help the model fit more easily. Plot the data as well.


### Prepare data for Poisson model ####
input_data <- list(
  N = nrow(island_plants),
  yy = island_plants$plant_rich,
  area = island_plants$hectare_area
)

mod <- cmdstan_model("Stan_models/S4a_Poisson.stan")

### Run Poisson model ####
stan_model <- mod$sample(
  data = input_data,
  iter_warmup = 2000,
  iter_sampling = 2000,
  chains = 4,
  parallel_chains = 4,
  refresh = 500 
)

### Poisson Analysis ####

#Let's save our MCMCsummary results
sum_diag <- MCMCsummary(stan_model,params=c("alpha","beta1"),pg0 = TRUE)
sum_diag

# At this point, everything should run without warnings, and we should get 
# the results we generally expect. However, that doesn't mean our model is doing
# a good job!

# We can extract our the mean estimates for our alpha and beta coefficients...
mean_alpha <- sum_diag$mean[1]
mean_beta <- sum_diag$mean[2]

# And use these to plot out the line of best fit
# This sets up a reasonable range for our xx's
xx_range <- seq(min(input_data$area),max(input_data$area),0.1)
#This gets the expected value at each xx point
yy <- qpois(0.5,exp(mean_alpha+mean_beta*xx_range))

#And this plots it out
plot(input_data$area,input_data$yy,pch=19,col="grey40",ylim=c(0,250))
points(xx_range,yy,type="l",col="orchid4",lwd=4)

# TODO(3) Does this line of best fit look good to you? Why or why not? What's the 
# predicted number of species at an 8 hectare island? Write your response below

### Posterior Predictive Check ####

# Posterior predictive checks allow us to see if our model does a good job
# of simulating data that has similar features to the real data. We want to know, 
# if we were asked to use our model to generate new data, does that data have 
# a similar distribution to the real data.

# TODO(4) Before moving on, head over to the S4a_Poisson.stan file. Take a look 
# at the generated quantities block, and read the text there.

# So, let's plot our real data
plot(density(input_data$yy,bw=5),ylim=c(0,0.05),xlim=c(0,300))

# Now we will extracted our generated samples from our model
simulated_values <- MCMCchains(stan_model,params="yy_rep")

#And then plot the first iteration of the simulated richness values
lines(density(simulated_values[1,],bw=5),col=alpha("red",0.9))

# We can also visualize our simulated data like this:
plot(input_data$area,input_data$yy,col="grey10",pch=19,ylim=c(0,300))
points(input_data$area,simulated_values[1,],col=alpha("red",.9),pch=19,cex=1)

# Lets do the same process, but with the first 100 iterations
plot(density(input_data$yy,bw=5),ylim=c(0,0.05),xlim=c(0,300))
for (nn in 1:100){
  lines(density(simulated_values[nn,],bw=10),col=alpha("red",0.1))
}

plot(input_data$area,input_data$yy,col="grey10",pch=19,ylim=c(0,300))
for (nn in 1:100){
  points(input_data$area,simulated_values[nn,],col=alpha("red",.2),pch=19,cex=.25)
}

# TODO(5) What's different about the real (black) and simulated (red) data distributions?
# Talk to a neighbor and write your answer below.

# TODO(6) Sometimes, all we need to do to make our model fit much better is to transform
# our covariates. Go back and change the input area data used for the model, 
# instead now taking the log() of the area_m2 column. Run your model again, making new plots
# for the line of best fit and the PPC. Do things fit better this time?

### Negative Binomial Model ####

# Lastly, let's try using another distribution to model the same data
# The negative binomial is often used for overdispersed data, using an extra parameter phi

### Prepare Data for NB model ####
input_data2 <- list(
  N = nrow(island_plants),
  yy = island_plants$plant_rich,
  area = NA # TODO (7) Add area data here again
)

mod <- cmdstan_model("Stan_models/S4b_NegativeBinomial.stan")

### Run NB model ####
stan_model2 <- mod$sample(
  data = input_data2,
  iter_warmup = 2000,
  iter_sampling = 2000,
  chains = 4,
  parallel_chains = 4,
  refresh = 500 
)


### NB Analysis ####
MCMCsummary(stan_model2)

#Let's save our MCMCsummary results
sum_diag2 <- MCMCsummary(stan_model2,params=c("alpha","beta1","phi"),pg0 = TRUE)
sum_diag2

mean_alpha2 <- sum_diag2$mean[1]
mean_beta2 <- sum_diag2$mean[2]

# And use these to plot out the line of best fit
# This sets up a reasonable range for our xx's
xx_range2 <- seq(min(input_data2$area),max(input_data2$area),0.1)
#This gets the expected value at each xx point
yy2 <- exp(mean_alpha2+mean_beta2*xx_range2)

plot(input_data$area,input_data2$yy,pch=19,col="grey40",ylim=c(0,250))
points(xx_range2,yy2,type="l",col="orchid4",lwd=4)

# So, let's plot our real data
plot(density(input_data2$yy,bw=5),ylim=c(0,0.05),xlim=c(0,300))

# Now we will extracted our generated samples from our model
simulated_values2 <- MCMCchains(stan_model2,params="yy_rep")

#And then plot the first iteration of the simulated richness values
lines(density(simulated_values2[1,],bw=5),col=alpha("red",0.9))

# We can also visualize our simulated data like this:
plot(input_data2$area,input_data2$yy,col="grey10",pch=19,ylim=c(0,300))
points(input_data2$area,simulated_values2[1,],col=alpha("red",.9),pch=19,cex=1)

# Lets do the same process, but with the first 100 iterations
plot(density(input_data2$yy,bw=5),ylim=c(0,0.05),xlim=c(0,300))
for (nn in 1:100){
  lines(density(simulated_values2[nn,],bw=10),col=alpha("red",0.1))
}

plot(input_data2$area,input_data2$yy,col="grey10",pch=19,ylim=c(0,300))
for (nn in 1:100){
  points(input_data2$area,simulated_values2[nn,],col=alpha("red",.25),pch=19,cex=.25)
}

# TODO (8) Which model (Poisson or NB) do you think is the best for your dataset here? 
# Explain why below.

