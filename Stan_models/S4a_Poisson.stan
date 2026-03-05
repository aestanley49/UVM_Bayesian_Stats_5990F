//Poisson Model

data {
  int<lower=0> N;
  array[N] int<lower=0> yy;
  vector[N] area;

}
parameters {
  //Set up parameters, alpha, beta1 
  real alpha;
  real beta1;
}

transformed parameters{
  vector[N] lin_pred; // Create our linear predictor variable
  vector<lower=0>[N] lambda; // Create lambda
  
  lin_pred = alpha+beta1*area; // Linear predictor equation
  lambda = exp(lin_pred); // Transform
}

model {
  alpha ~ normal(0,3);
  beta1 ~ normal(0,1);

  yy ~ poisson(lambda);
}

// Here we have a new block that allows us to simulate data using our model above^
generated quantities{
  // This creates a new variable that will represent model-generated data
  array[N] int<lower=0> yy_rep; 
  
  // See how the line below is basically a copy of the model line above.
  // Here though, we use an equal sign and the "_rng" function to simulate
  // new yys. Think of this as a random number generator, with the new yy_reps
  // being drawn from our model estimated distribution.
  yy_rep = poisson_rng(lambda);
}
