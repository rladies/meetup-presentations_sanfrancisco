library(rstantools)
library(rstanarm)
library(brms)
library(rstan)
library(shiny)


#########################################################
#                       R-STAN
#########################################################


my_wonderful_model <- '
 // read in data ...
  data {
  int<lower=0> N;
  vector[N] X;
  vector[N] Y;
  }
    // Declare parameters that will be estimated
parameters {
  real alpha;
  real beta;
  real<lower=0> sigma;
}
    // Create new variables/auxiliary variables from the data
transformed parameters {
  vector[N] y_hat;
  y_hat = beta * X + alpha; 
}
    // Declare your probability model: priors, hyperpriors & likelihood
model {
  Y ~ normal(y_hat, sigma);
// priors
  alpha ~ normal(0,1);
  beta  ~ normal(0,0.5);
  sigma ~ cauchy(0,1);
// likelihood
  Y ~ normal(y_hat, sigma);
}
'

# Specify the data using the dataset mtcars
my_data <- list(
  'N' = length(mtcars$mpg),
  'X' = mtcars$wt,
  'Y' = mtcars$mpg)


# Run my STAN code via rstan
fit_1 <- stan(model_code =  my_wonderful_model,
              data = my_data,
              iter = 2000,                         # number of Markov chains
              warmup = 1000,                       # number of warmup iterations per chain
              chains = 4,                          # total number of iterations per chain
              cores = 2,                           # number of cores (could use one per chain)
              seed = 1234)


fit_2 <- stan(file = "/home/alice/Dropbox/Presentation Bayesian/R-Ladies/mtcars.stan",  # Stan program
              data = my_data,
              iter = 2000,
              warmup = 1000,
              chains = 4,
              cores = 2,
              seed = 1234)

estimates <- rstan::extract(fit_1, permuted = TRUE)
alpha <- as.data.frame(estimates$alpha)
  
plot(density(estimates$alpha))


############################################
#   Linear Regression
############################################

#Rstanarm
lm_rstan <- stan_glm(formula = mpg ~ wt + am + cyl, 
         data = mtcars, 
         prior = NULL, 
         family = gaussian(),
         chains = 4, 
         iter = 2000,
         warmup = 1000,
         cores = 2,
         seed = 1234)

# plot
plot(lm_rstan)
#ShinyStan Diagnostic and more
launch_shinystan(lm_rstan)

#Brms
lm_brms <- brm(formula = mpg ~ wt + am + cyl, 
    data = mtcars, 
    prior = NULL, 
    family  = "gaussian", 
    chains = 4, 
    iter = 2000, 
    warmup = 1000, 
    cores = 2,
    seed = 1234)

# plot
plot(lm_brms)
#ShinyStam
launch_shinystan(lm_brms)


############################################
#       Random Effects Regrassions
############################################

#Rstanarm
re_rstan <- stan_glmer(formula = mpg ~ wt + am + (1|cyl), 
           data = mtcars, 
           prior = NULL, 
           family = gaussian(), 
           chains=4, 
           iter=2000,
           warmup=1000,
           cores = 2,
           seed = 1234)


# Brms
re_brms <- brm(formula = mpg ~ wt + am + (1|cyl), 
    data = mtcars, 
    prior = NULL, 
    family="gaussian", 
    chains=4, 
    iter=2000, 
    warmup=1000,
    cores = 2,
    seed = 1234)


############################################
#     Smooth Terms Regrassions (GAM)
############################################

#Rstanarm
gam_rstan <- stan_gamm4(formula = mpg ~ s(wt) + am, 
           data = mtcars, 
           prior = NULL, 
           family = gaussian(), 
           chains=4, 
           iter=2000, 
           warmup=1000,
           cores = 2,
           seed = 1234)

#Brms
gam_brms <- brm(formula = mpg ~ s(wt) + am, 
                        data = mtcars, 
                        prior = NULL, 
                        family = "gaussian", 
                        chains=4, 
                        iter=2000, 
                        warmup=1000,
                        cores = 2,
                        seed = 1234)

#plot smooth effect
plot(marginal_effects(gam_brms, effects = "wt"))


##############################################
#           PRIOR DISTRIBUTIONS
##############################################

get_prior(formula = mpg ~ wt + am + (1|cyl), data = mtcars, family="gaussian")


my_priors <- c(set_prior("normal(0,10)", class = "b"), 
           set_prior("normal(1,2)", class = "b", coef = "wt"), # Break vectorization,  it may slow down the process.
           set_prior("cauchy(0,2)", class = "sd", group = "cyl", coef = "Intercept"), # Sd of group-level (’random’) effects
           set_prior("student_t(3, 0, 10)", class = "sigma"))


my_prior_model <- brm(mpg ~ wt + am + (1|cyl), 
    data = mtcars, 
    prior = my_priors)



##############################################
#           MAKE STAN CODE
##############################################

make_stancode(mpg ~ wt + am + cyl, data = mtcars, prior = NULL, family  = "gaussian")


##############################################
#          RESIDUALS CORRELATION
##############################################

cor_brms <- brm(mpg ~ wt + am + (1|cyl), 
    data = mtcars, 
    prior = NULL,
    family="gaussian", 
    cor_arma(formula = ~1, q = 1))




