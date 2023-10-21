# ------------------------------------------------------------------------------
# Title: Modeling Runoff Water Quality using Markov-Chain Monte Carlo Techniques
# Author: A.J. Brown
# Role: Agricultural Data Scientist
# 
# Description:
# This script focuses on the application of Markov-Chain Monte Carlo (MCMC) techniques 
# to model runoff water quality. I then illustrate a similar, frequentist linear
# mixed model (LMM) with random effects to compare results. This project 
# represents my first endeavor into the world of MCMC methodologies, 
# with the goal of enhancing our understanding and predictive abilities 
# regarding runoff water quality.
# ------------------------------------------------------------------------------

# ------------------------------------------------------------------------------

# Import libraries
package.list <- c(
    'nimble',
    'coda',
    'lme4'
    )
packageLoad <- function(packages){
  for (i in packages) {
    if (!require(i, character.only = TRUE)) {
      install.packages(i)
      library(i, character.only = TRUE)
    }
  }
}
packageLoad(package.list)

# Import data
tss_df <- read.csv("data_filename.csv", header = TRUE)

# View the first few rows of the dataset
head(tss_df)

# Get a summary of the dataset
summary(tss_df)

# ------------------------------------------------------------------------------
# MCMC Model Developed by A.J. Brown using NIMBLE
# Use the NIMBLE cheatsheet to help with the syntax:
# https://r-nimble.org/cheatsheets/NimbleCheatSheet.pdf
# https://r-nimble.org/bayesian-nonparametric-models-in-nimble-part-2-nonparametric-random-effects

code <- nimbleCode({
  # Fixed effects
  beta0 ~ dnorm(0, sd = 100)
  betaTrt ~ dnorm(0, sd = 100)
  betaYear ~ dnorm(0, sd = 100)
  betaInteraction ~ dnorm(0, sd = 100)

  # Random effects
  for(j in 1:nyi) {
    u_yi[j] ~ dnorm(0, tau_yi)
  }
  
  for(j in 1:nblock) {
    u_block[j] ~ dnorm(0, tau_block)
  }
  
  for(j in 1:nid) {
    u_id[j] ~ dnorm(0, tau_id)
  }

  tau_yi ~ dunif(0, 100)
  tau_block ~ dunif(0, 100)
  tau_id ~ dunif(0, 100)
  
  sigma ~ dunif(0, 100) # prior for variance components based on Gelman (2006)
  
  for(i in 1:n) {
    tss[i] ~ dnorm(beta0 + betaTrt*trt[i] + betaYear*year[i] + betaInteraction*trt[i]*year[i] + 
                   u_yi[yi[i]] + u_block[block[i]] + u_id[id[i]], sd = sigma)
  }
})

# Extract data for predictors and center
trtCentered <- tss_df$trt - mean(tss_df$trt)
yearCentered <- tss_df$year - mean(tss_df$year)

# constants for the model e.g., for-loop ranges, known index vectors
constants <- list(
    n = nrow(tss_df), 
    nyi = length(unique(tss_df$yi)), 
    nblock = length(unique(tss_df$block)), 
    nid = length(unique(tss_df$id)), 
    trt = trtCentered, 
    year = yearCentered
    )
# values to label as data nodes
data <- list(
    tss = tss_df$tss, 
    yi = as.numeric(tss_df$yi), 
    block = as.numeric(tss_df$block), 
    id = as.numeric(tss_df$id)
    )
# initial values for parameters
inits <- list(
    beta0 = mean(tss_df$tss),
    betaTrt = 0, 
    betaYear = 0, 
    betaInteraction = 0, 
    sigma = 1, 
    tau_yi = 1, 
    tau_block = 1, 
    tau_id = 1, 
    u_yi = rep(0, constants$nyi), 
    u_block = rep(0, constants$nblock), 
    u_id = rep(0, constants$nid)
    )
# Build the model
    # Note: constants can’t be changed after creating a model;
    # data & inits can be changed.
model <- nimbleModel(
    code, 
    constants = constants, 
    data = data, 
    inits = inits
    )

# Configure MCMC samplers
mcmcConf <- configureMCMC(model)
mcmcConf$printSamplers()

# ------------------------------------------------------------------------------
# Original Frequentist Model developed by Deleon and Hess
modtssm <- lmer(tssl~trt*year+(1|yi)+(1|block)+(1|id), data = tss_df)
anova(modtssm, ddf = "Kenward-Roger")