// Hierarchical Model

data {
  int<lower=0> N;
  vector[N] yy; // Arrival date
  vector[N] year; // Year
  
  int<lower=0> N_sp_areas; // The total number of areas
  array[N] int<lower=1,upper=N_sp_areas> sp_ar; // Area index (1:N_areas)
  
  int<lower=0> N_sp; // The total number of species
  array[N_sp_areas] int<lower=1,upper=N_sp> sp; // species index (1:N_sp)
}

parameters {
  
  real theta;
  real<lower=0> sigma_mu_alpha;
  
  real omega;
  real<lower=0> sigma_mu_beta;
  
  vector[N_sp] mu_alpha; 
  real<lower=0> sigma_alpha;
  
  vector[N_sp] mu_beta;
  real<lower=0> sigma_beta;
  vector[N_sp_areas] beta;
  
  vector[N_sp_areas] alpha;
  real<lower=0> sigma;
}

model {
  
  theta ~ normal(0,10);
  sigma_mu_alpha ~ lognormal(2,1);
  
  omega ~ normal(0,10);
  sigma_mu_beta ~ gamma(3,2);
  
  mu_alpha ~ normal(theta,sigma_mu_alpha);
  mu_beta ~ normal(omega,sigma_mu_beta);
  
  sigma_alpha ~ lognormal(2,1); 
  
  sigma_beta ~ gamma(3,2);
  
  alpha ~ normal(mu_alpha[sp],sigma_alpha);
  beta ~ normal(mu_beta[sp],sigma_beta);
  sigma ~ lognormal(1,1);

  yy ~ normal(alpha[sp_ar] + beta[sp_ar] .* year, sigma);
  
}

