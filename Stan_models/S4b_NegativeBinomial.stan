//Negative Model

data {
  int<lower=0> N;
  array[N] int<lower=0> yy;
  vector[N] area;

}
parameters {
  //Set up three parameters, alpha, beta1 and phi (variance)
  real alpha;
  real beta1;
  real<lower=0> phi;
}

// Here we have a new block used for parameters that are derivative 
transformed parameters{
  vector[N] lin_pred; // Create our linear predictor variable
  vector<lower=0>[N] lambda; // Create lambda
  
  lin_pred = alpha+beta1*area; // Linear predictor equation
  lambda = exp(lin_pred); // Transform
}


model {
  alpha ~ normal(0,5);
  beta1 ~ normal(0,1);
  phi ~ normal(0,100);
  
  yy ~ neg_binomial_2(lambda,phi);
}

// Here we have a new block that allows us to simulate data.
generated quantities{
  array[N] int<lower=0> yy_rep; // This creates a new variable that will represent model-generated data
  
  // See how the line below is basically a copy of the model line above.
  // Here though, we use an equal sign and the "_rng" function to simulate
  // new yys.
  yy_rep = neg_binomial_2_rng(lambda,phi);
}
