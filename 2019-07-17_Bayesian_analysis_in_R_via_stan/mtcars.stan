  data {
  int<lower=0> N;
  vector[N] X;
  vector[N] Y;
  }
parameters {
  real alpha;
  real beta;
  real<lower=0> sigma;
}
transformed parameters {
  vector[N] y_hat;
  y_hat = beta * X + alpha; 
}
model {
  Y ~ normal(y_hat, sigma);
// priors
  alpha ~ normal(0,1);
  beta  ~ normal(0,0.5);
  sigma ~ cauchy(0,1);
// likelihood
  Y ~ normal(y_hat, sigma);
}
