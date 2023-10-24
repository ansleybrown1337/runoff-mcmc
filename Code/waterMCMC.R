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

# Set working directory to runoff-mcmc folder
setwd(dirname(getwd()))

# Import libraries
package.list <- c(
    'nimble',
    'coda',
    'lme4',
    'lmerTest',
    'lsmeans',
    'ggplot2',
    'dplyr',
    'tidyr'
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
tss_df <- read.csv("./Example Data/tss.csv", header = TRUE)

# View the first few rows of the data to ensure proper import
head(tss_df)

# Convert columns to their respective data types
tss_df$date <- as.Date(tss_df$date, format="%m/%d/%Y")
tss_df$year <- as.factor(tss_df$year)
tss_df$yi <- as.factor(tss_df$yi)
tss_df$id <- as.factor(tss_df$id)
tss_df$block <- as.factor(tss_df$block)
tss_df$trt <- as.factor(tss_df$trt)
tss_df$irr <- as.factor(tss_df$irr)
tss_df$tss <- as.numeric(tss_df$tss)
tss_df$out <- as.numeric(tss_df$out)
tss_df$tssl <- as.numeric(tss_df$tssl)

# Print the structure of the dataframe to confirm data types
str(tss_df)

# Get a summary of the data
summary(tss_df)

# note on building priors for MCMC analysis:
# For fixed effects: Using a prior centered around zero, but with a 
# standard deviation (sd) that's slightly larger than the tss sample 
# standard deviation of tss, which is 0.71 mg/L and 22.15 kg, respectively. 
# For random effects: 
#   tau_yi:
#   Prior: dunif(0, 1.5)
#   Explanation: The uniform prior is based on the observed yearly variability. 
#   The maximum observed standard deviation across yi's is 0.801, so the upper 
#   bound is set slightly higher at 1.5 to capture potential variability.
#
#   tau_block:
#   Prior: dunif(0, 1)
#   Explanation: Same reasoning as tau_yi but by block
#
#   tau_id:
#   Prior: dunif(0, 1.5)
#   Explanation: 
#
#   u_yi, u_block, u_id:
#   Priors: Each u term (representing random effects for yi, block, and id) is 
#   drawn from a normal distribution centered at zero with the respective 
#   standard deviation (tau_yi, tau_block, or tau_id).
#   Explanation: This captures the random variability across years (yi), blocks,
#   and IDs.
#
#   sigma:
#   Prior: dunif(0, 2)
#   Explanation: This is a broad prior for the residual error. Given the sample standard deviation of tss is 0.71, setting an upper bound of 2 allows the model to capture potential larger variabilities in the residuals.

recommend_priors <- function(df, column_name) {
  # Ensure column_name exists in the dataframe
  if (!(column_name %in% colnames(df))) {
    stop(paste0("The column '", column_name, "' does not exist in the dataframe."))
  }
  
  cat(paste0("Recommended priors based on column: '", column_name, "'\n\n"))
  
  # Compute the maximum standard deviation for each effect
  max_sd <- df %>%
    summarise(
      trt = max(tapply(.data[[column_name]], trt, sd)),
      block = max(tapply(.data[[column_name]], block, sd)),
      year = max(tapply(.data[[column_name]], year, sd)),
      yi = max(tapply(.data[[column_name]], yi, sd)),
      id = max(tapply(.data[[column_name]], id, sd))
    )
  
  # Double the max standard deviation and round to the nearest whole number
  doubled_rounded <- round(2 * max_sd)
  
  # Combine the results into a table
  recommended_prior_table <- bind_cols(
    effect = names(max_sd),
    identified_max = as.numeric(max_sd),
    recommended_prior = as.numeric(doubled_rounded)
  )
  
  return(recommended_prior_table)
}

# Test the function
priors_tss <- recommend_priors(tss_df, 'tss')
priors_tss
priors_tssl <- recommend_priors(tss_df, 'tssl')
priors_tssl

# ------------------------------------------------------------------------------
# MCMC Model Developed by A.J. Brown using NIMBLE
# Use the NIMBLE cheatsheet to help with the syntax:
# https://r-nimble.org/cheatsheets/NimbleCheatSheet.pdf
# https://r-nimble.org/bayesian-nonparametric-models-in-nimble-part-2-nonparametric-random-effects

# Step 1: Build the model
code <- nimbleCode({
  # note on building priors:
    # For fixed effects: Using a prior centered around zero, but with a 
    # standard deviation (sd) that's slightly larger than the tss sample 
    # standard deviation of tss, which is 0.71 mg/L and . 
  
  
  # Fixed effects
  beta0 ~ dnorm(0, sd = 0.8)
  
    # Looping over the elements of betaTrt and betaYear
  for(k in 1:3) {
    betaTrt[k] ~ dnorm(0, sd = 0.8)
  }
  for(k in 1:maxYear) {
    betaYear[k] ~ dnorm(0, sd = 0.8)
  }
  
  # Random effects
  # Gelman (2006) recommends the uniform prior on the sd scale not the precision scale for random effects:
  # E.g., u_yi[j] ~ dnorm(0, sd = tau_yi) NOT u_yi[j] ~ dnorm(0, tau_yi)
  
  # yi
  for(j in 1:nyi) {
    u_yi[j] ~ dnorm(0, sd = tau_yi)
  }
  # block
  for(j in 1:nblock) {
    u_block[j] ~ dnorm(0, sd = tau_block)
  }
  # id
  for(j in 1:nid) {
    u_id[j] ~ dnorm(0, sd = tau_id)
  }
  
  tau_yi ~ dunif(0, 2)
  tau_block ~ dunif(0, 2)
  tau_id ~ dunif(0, 2)
  
  sigma ~ dunif(0, 2) # prior for variance components based on Gelman (2006); 
  
  for(i in 1:n) {
    tss[i] ~ dnorm(beta0 + betaTrt[trt[i]] + betaYear[year[i]] + 
                     u_yi[yi[i]] + u_block[block[i]] + u_id[id[i]], sd = sigma)
  }
})

constants <- list(
  n = nrow(tss_df), 
  nyi = length(unique(tss_df$yi)), 
  nblock = length(unique(tss_df$block)), 
  nid = length(unique(tss_df$id)), 
  maxYear = length(unique(tss_df$year)),
  # Converting factors to numeric below for MCMC
  trt = as.numeric(tss_df$trt),
  yi = as.numeric(tss_df$yi),
  id = as.numeric(tss_df$id),
  year = as.numeric(tss_df$year),
  block = as.numeric(tss_df$block)
)

data <- list(
  tss = tss_df$tss 
)

inits <- list(
  beta0 = mean(tss_df$tss),
  betaTrt = rep(0, 3), # Initial values for three levels of 'trt'
  betaYear = rep(0, constants$maxYear),
  sigma = 1, 
  tau_yi = 1, 
  tau_block = 1, 
  tau_id = 1, 
  u_yi = rep(0, constants$nyi), 
  u_block = rep(0, constants$nblock), 
  u_id = rep(0, constants$nid)
)

TSSmodel <- nimbleModel(
  code, 
  constants = constants, 
  data = data, 
  inits = inits
)

# Step 2: Build the MCMC
TSSmcmc <- buildMCMC(TSSmodel, enableWAIC = TRUE)

# Step 3: Compile the model and MCMC
cTSSmodel <- compileNimble(TSSmodel)
cTSSmcmc <- compileNimble(TSSmcmc, project = TSSmodel)

# Step 4: Run the MCMC
time_baseline <- system.time(TSSresults <- runMCMC(cTSSmcmc,
                                                  niter=11000,
                                                  nburnin=1000,
                                                  WAIC=TRUE)
                                                  )
cat("Sampling time: ", time_baseline[3], "seconds.\n")

# Step 5: Extract the samples and WAIC
  # Samples
samples <- TSSresults$samples

  # Watanabe-Akaike Information Criterion (WAIC): captures model fit
  # Log Pointwise Predictive Density (LPPD): captures model complexity
  # effective number of parameters in the model (pWAIC): balances previous two
  # The relationship: WAIC=−2×lppd+2×pWAIC
WAIC <- TSSresults$WAIC
WAIC


# Step 6: Inspect Results
plot(as.mcmc(samples))
dev.off()




# ------------------------------------------------------------------------------
# Original Frequentist Model developed by Deleon and Hess
modtssm <- lmer(tssl~trt*year+(1|yi)+(1|block)+(1|id), data = tss_df)

# Check model assumptions
summary(modtssm)
anova(modtssm, ddf = "Kenward-Roger")
plot(modtssm) # a bit heteroskedastic if you ask me :)

# Some result notes by AJB
# Random Effects Variances: The variance for the random effect (1|id) is 0, and for (1|block), it's very close to zero. This suggests that the model cannot estimate variability for these random effects given the data. In other words, the random intercepts for id are redundant, and those for block provide minimal information.
# Fixed Effects: The fixed effects seem to have been estimated without any issues.
# 
# Given this output, here's what we should consider:
# - Remove (1|id) Random Effect: Since its variance is exactly zero, it means that this random effect does not contribute to the model. Removing it may lead to a better model fit without the singularity issue.
# - Reconsider (1|block) Random Effect: Its variance is very close to zero. You might want to test the model without this random effect and see if the model fit improves.
# - Refit the Model: After removing or adjusting the random effects, refit the model and check if the singularity warning goes away:


# Get the pairwise comparisons output
lsm_output <- lsmeans(modtssm, pairwise~trt|year)

# Convert the lsmeans to a dataframe
lsm_df <- as.data.frame(lsm_output$lsmeans)
# Create a new variable combining treatment and year for plotting on the x-axis
lsm_df$trt_year <- paste(lsm_df$trt, lsm_df$year, sep="_")


# Create the forest plot by year
plt_yr <- ggplot(lsm_df, aes(x=trt, y=lsmean, ymin=lower.CL, ymax=upper.CL, group=year)) +
  geom_point(aes(color=trt), size=3) +
  geom_errorbar(aes(color=trt), width=0.2) +
  facet_wrap(~year, scales="free_x") +
  theme_minimal() +
  labs(y="Estimated TSS Mean (mg/L)", x="Treatment") +
  theme(legend.position="bottom")
plt_yr

# Create the forest plot over all years by trt
plt_all <- ggplot(lsm_df, aes(x=trt_year, y=lsmean, ymin=lower.CL, ymax=upper.CL, group=trt_year)) +
  geom_point(aes(color=trt), size=3) +
  geom_errorbar(aes(color=trt), width=0.2) +
  theme_minimal() +
  labs(y="Estimated TSS Mean (mg/L", x="Treatment-Year Combination") +
  theme(legend.position="bottom", axis.text.x = element_text(angle = 45, hjust = 1))
plt_all

# Save output images
ggsave(filename = "Output/forest_plot_yr_LMM.png", plot = plt_yr, width = 10, height = 6, dpi = 300)
ggsave(filename = "Output/forest_plot_all_LMM.png", plot = plt_all, width = 10, height = 6, dpi = 300)




