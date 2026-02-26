// Simple linear regression from: https://mc-stan.org/docs/stan-users-guide/linear-regression.html
data {
  int<lower=0> N;
  array[N] int<lower=0, upper=1> yy;
  vector[N] xx1;

}

parameters {
  real alpha;
  real beta1;
}

// To incorporate a linear predictor and a link function, we do this is in a new "block."
// Not th
transformed parameters{
  vector[N] lin_pred; // Create linear predictor
  vector<lower=0,upper=1>[N] pp; // Create probability (pp)
  
  lin_pred = alpha+beta1*xx1; // Linear predictor equation
  pp = inv_logit(lin_pred); // link function equation
}

model {
  //Priors
  alpha ~ normal(0,10);
  beta1 ~ normal(0,10);
  
  // Model code
  yy ~ bernoulli(pp);
}
