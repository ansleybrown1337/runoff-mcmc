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
  'BayesianTools',  
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
assign_type <- function(df) {
  df$date <- as.Date(df$date, format="%m/%d/%Y")
  df$year <- as.factor(df$year)
  df$yi <- as.factor(df$yi)
  df$id <- as.factor(df$id)
  df$block <- as.factor(df$block)
  df$trt <- as.factor(df$trt)
  df$irr <- as.factor(df$irr)
  df$tss <- as.numeric(df$tss)
  df$out <- as.numeric(df$out)
  df$tssl <- as.numeric(df$tssl)
  
  return(df)
}
tss_df <- assign_type(tss_df)

# Print the structure of the dataframe to confirm data types
str(tss_df)

# Get a summary of the data
summary(tss_df)

# Declare the water analyte we're interested in
analyte <- 'tss'
tss_df$analyte <- tss_df[[analyte]]

# Convert data back to numbers and add center columns
center_data <- function(df) {
  # Ensure that columns are numeric
  df$analyte = as.numeric(df$analyte)
  df$trt = as.numeric(df$trt)
  df$yi = as.numeric(df$yi)
  df$id = as.numeric(df$id)
  df$year = as.numeric(df$year)
  df$block = as.numeric(df$block)
  
  # Center each column by subtracting its mean
  df$analyte_ctr = df$analyte - mean(df$analyte, na.rm = TRUE)
  df$trt_ctr = df$trt - mean(df$trt, na.rm = TRUE)
  df$yi_ctr = df$yi - mean(df$yi, na.rm = TRUE)
  df$id_ctr = df$id - mean(df$id, na.rm = TRUE)
  df$year_ctr = df$year - mean(df$year, na.rm = TRUE)
  df$block_ctr = df$block - mean(df$block, na.rm = TRUE)
  
  return(df)
}
tss_df <- center_data(tss_df)
# Creating starting values from std. dev.'s for MCMC (see README.md notes on this)
recommend_starting_vals <- function(df, column_name) {
  # Ensure column_name exists in the dataframe
  if (!(column_name %in% colnames(df))) {
    stop(paste0("The column '", column_name, "' does not exist in the dataframe."))
  }

  # Compute the maximum standard deviation for each effect
  max_sd <- df %>%
    summarise(
      trt = max(tapply(.data[[column_name]], trt, sd)),
      block = max(tapply(.data[[column_name]], block, sd)),
      year = max(tapply(.data[[column_name]], year, sd)),
      yi = max(tapply(.data[[column_name]], yi, sd)),
      id = max(tapply(.data[[column_name]], id, sd)),
      all = sd(.data[[as.name(column_name)]], na.rm = TRUE)
    )
  
  # Compute the mean for each effect
  effect_mean <- df %>%
    summarise(
      trt = mean(tapply(.data[[column_name]], trt, mean)),
      block = mean(tapply(.data[[column_name]], block, mean)),
      year = mean(tapply(.data[[column_name]], year, mean)),
      yi = mean(tapply(.data[[column_name]], yi, mean)),
      id = mean(tapply(.data[[column_name]], id, mean)),
      all = mean(.data[[as.name(column_name)]], na.rm = TRUE)
    )
  
  # Double the max standard deviation and round to the nearest whole number
  # doubled_rounded <- round(2 * max_sd)
  
  # Combine the results into a table
  recommended_sv_table <- bind_cols(
    effect = names(max_sd),
    max_sd = as.numeric(max_sd),
    mean = as.numeric(effect_mean)
  )
  print(recommended_sv_table)
  return(recommended_sv_table)
}

# Test the function
sv <- recommend_starting_vals(tss_df, 'analyte_ctr')


# ------------------------------------------------------------------------------
# MCMC Model Developed by A.J. Brown using NIMBLE
# Use the NIMBLE cheatsheet to help with the syntax:
# https://r-nimble.org/cheatsheets/NimbleCheatSheet.pdf
# https://r-nimble.org/bayesian-nonparametric-models-in-nimble-part-2-nonparametric-random-effects

# cross-effect; when the y-var experiences all levels of another effect
# nested effect; adding repetitions of your data (e.g., block)

# Step 1: Build the model
code <- nimbleCode({
  # This is where we define parameters and set priors.
  # DO NOT SET PRIORS USING YOUR DATA TO INFORM THEM
  
  # Fixed effects
    # consider dropping this beta_0 since it offers no additional functionality;
    # this would mean the model intercept would default to CT, likely.
  # beta0 ~ dnorm(0, sd = 0.8)
  
    # Looping over the elements of betaTrt and betaYear
  for(k in 1:3) {
    betaTrt[k] ~ dnorm(0, sd = 1)
  }
  for(k in 1:maxYear) {
    betaYear[k] ~ dnorm(0, sd = 1)
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
  
  tau_yi ~ dunif(0, 1)
  tau_block ~ dunif(0, 1)
  tau_id ~ dunif(0, 1)
  
  sigma ~ dunif(0, 1) # prior for variance components based on Gelman (2006); 
  
  # reduced model: I'd like to remove yi, block, and id
  for(i in 1:n) {
    y[i] ~ dnorm(
                betaTrt[trt[i]] +
                betaYear[year[i]] +
                u_yi[yi[i]] +
                u_block[block[i]] +
                u_id[id[i]],
                sd = sigma
                 )
  }
  
  # Other models to consider, just commented out for reference:
  # 'full model'
  # for(i in 1:n) {
  #   tss[i] ~ dnorm(beta0 + betaTrt[trt[i]] + betaYear[year[i]] + 
  #                    u_yi[yi[i]] + u_block[block[i]] + u_id[id[i]], sd = sigma)
  # }
  # 'no-intercept/B0 model'
  # for(i in 1:n) {
  #   y[i] ~ dnorm(betaTrt[trt[i]] + betaYear[year[i]] + 
  #                    u_yi[yi[i]] + u_block[block[i]] + u_id[id[i]], sd = sigma)
  # }
})

constants <- list(
  n = nrow(tss_df), 
  nyi = length(unique(tss_df$yi)), 
  nblock = length(unique(tss_df$block)), 
  nid = length(unique(tss_df$id)), 
  maxYear = length(unique(tss_df$year)),
  trt = tss_df$trt,
  yi = tss_df$yi,
  id = tss_df$id,
  year = tss_df$year,
  block = tss_df$block
)

data <- list(
  y = tss_df$analyte_ctr
)

inits <- list(
  # let's use the results from our estimation function here to guess sv's
  #beta0 = mean(tss_df$tss),
  betaTrt = rep(0, 3), # Initial values for three levels of 'trt'
  betaYear = rep(0, constants$maxYear),
  sigma = sv$max_sd[6], # using std. dev. of analyte_ctr from sv tibble 
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
cTSSmodel <- compileNimble(TSSmodel,showCompilerOutput = TRUE)
cTSSmcmc <- compileNimble(TSSmcmc, project = TSSmodel)

# Step 4: Run the MCMC
time_baseline <- system.time(
  TSSresults <- runMCMC(cTSSmcmc,
                        niter=11000,
                        nburnin=1000, # change to 0 if you want to see burn in
                        WAIC=TRUE,
                        nchains=1)
  )
cat("Sampling time: ", time_baseline[3], "seconds.\n")

# Step 5: Extract the samples and WAIC
  # Samples
samples <- TSSresults$samples
colnames(samples)
summary(samples)
  # Watanabe-Akaike Information Criterion (WAIC): captures model fit
  # Log Pointwise Predictive Density (LPPD): captures model complexity
  # effective number of parameters in the model (pWAIC): balances previous two
  # The relationship: WAIC=−2×lppd+2×pWAIC
WAIC <- TSSresults$WAIC
WAIC

# Step 6: Inspect Convergence
# TODO: learn how to plot 95% CIs on marginal density plots
pdf('./Output/trace_density_plots.pdf')
plot(as.mcmc(samples))
dev.off()

pdf('./Output/correlation_plots.pdf')
correlationPlot(samples)
dev.off()

marginalPlot(samples)



# ------------------------------------------------------------------------------
# Original Frequentist Model developed by Deleon and Hess
modtssm <- lmer(tssl~trt*factor(year)+(1|yi)+(1|block)+(1|id), data = tss_df)

# Issue with the above model: year is not a factor, but a continuous variable.
# as such, if you try to correct it, you get a singularity error. This is
# because the model doesn't have enough degrees of freedom to fit the model

# New model: tssl~trt*year+irr+(1|block)
# - AJ and Tad 15 Dec 2023

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
  labs(y="Estimated TSS Load (kg)", x="Treatment-Year Combination") +
  theme(legend.position="bottom", axis.text.x = element_text(angle = 45, hjust = 1))
plt_all

# Save output images
ggsave(filename = "Output/forest_plot_yr_LMM.jpg", plot = plt_yr, width = 10, height = 6, dpi = 300)
ggsave(filename = "Output/forest_plot_all_LMM.jpg", plot = plt_all, width = 10, height = 6, dpi = 300)




