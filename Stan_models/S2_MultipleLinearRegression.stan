// Simple linear regression from: https://mc-stan.org/docs/stan-users-guide/linear-regression.html
data {
  int<lower=0> N;
  vector[N] ch_s;
  // TODO (5) Add hh in here 
  //hint: it's easiest to define as a vector with limits <lower=0,upper=1> with [length] called hh (in that order);

  vector[N] lai;
}

parameters {
  real alpha;
  real beta;
  // TODO (6) Add the parameter "theta" in here

  real<lower=0> sigma;
}

model {
  //Priors
  alpha ~ normal(0,10);
  beta ~ normal(0,10);
  
  // TODO (7) Set a prior for theta here

  sigma ~ gamma(3,2);
  
  // TODO (8) Update the line below to include the parameter theta, and the variable hh
  
  lai ~ normal(alpha+beta*ch_s,sigma);
}
