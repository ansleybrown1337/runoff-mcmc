![Banner](/images/banner.png)
# Modeling Runoff Water Quality using Markov-Chain Monte Carlo Techniques in R
_By A.J. Brown, Agricultural Data Scientist_

> [!WARNING]  
> This project is not yet complete, so this code is not yet fully functional.  This notice will be removed when a first version is successful and online.

Here, we explore the application of [Markov chain Monte Carlo (MCMC) techniques](https://towardsdatascience.com/monte-carlo-markov-chain-mcmc-explained-94e3a6c8de11) to model runoff water quality using a Bayesian approach. We also compare results from a Frequentist linear mixed model (LMM) This project signifies my inaugural venture into leveraging MCMC methodologies, aiming to provide a deeper understanding and predictive capabilities for runoff water quality.

For a nice discussion on Frequentist v. Bayesian theory, check out [this article from the National Institue of Health (NIH)](https://www.ncbi.nlm.nih.gov/pmc/articles/PMC6406060/).

## Key Features:
- **Programming Language:** R
- **Key Package:** [NIMBLE](https://r-nimble.org/)
- **Technique:** Markov-Chain Monte Carlo (MCMC)

The repository is structured to guide you through the entire process, from data preprocessing to model evaluation. Whether you're an environmental scientist, a data analyst, or someone with a keen interest in water quality modeling, this repository offers insights into the potential of MCMC techniques in the field.

Feel free to explore the code, datasets, and documentation. Your contributions, feedback, and suggestions are always appreciated!

## Table of Contents

- [Directory Structure](#directory-structure)
- [Getting Started](#getting-started)
- [Running the Model](#running-the-model)
- [Data Structure](#data-structure)
- [Selecting Starting Values and Priors for MCMC Analysis](#selecting-starting-values-and-priors-for-mcmc-analysis)
- [Results of Analysis](#results-of-analysis)
- [Contribute](#contribute)
- [License](#license)
- [References](#references)

## Directory Structure

- `Code`: This directory contains the R code for analysis.
- `Example Data`: Sample dataset that I'm using to test my analysis.
- `images`: Contains banner image.
- `Output`: Where output images and results will be saved.

## Getting Started

1. Clone the repository:
```bash
git clone https://github.com/your-username/runoff-mcmc.git
cd runoff-mcmc
```

2. Open the R code in the repository using an IDE like Rstudio or VS code.

3. Install NIMBLE.
> [!IMPORTANT]  
> Before installing NIMBLE, you need a compiler and related tools such as make that R can use. For Windows users, this is [Rtools](http://cran.r-project.org/bin/windows/Rtools), and for Mac users it is [Xcode](https://mac.install.guide/commandlinetools/4.html#:~:text=Use%20'xcode%2Dselect'%20to%20install%20Xcode%20Command%20Line%20Tools&text=The%20command%20xcode%2Dselect%20%2D%2Dinstall%20will%20open%20a%20dialog,of%20the%20command%20line%20tools.&text=You'll%20see%20a%20panel,the%20download%20and%20installation%20process.).

## Running the Model
1. **Load the Dataset:** Ensure the dataset is in the correct path or adjust the path in the script accordingly.

2. **Run the Script:** Execute the R script. This will initiate the MCMC process and might take some time, depending on the dataset's size and the number of iterations.

3. **View the Results:** Once the script completes, you'll be able to see the model's results, including any plots or graphs generated.

## Data Structure

The example data provided is runoff water sediment concentration and load measured from a surface-irrigated, agricultural research field with various tillage treatments from 2011 - 2017.

The columns present in the CSV are as follows:

- **date (Date)**: Date of sample collection
- **year (Factor)**: Year of sample collection
- **yi (factor)**: Combination of year and irrigation events as a single factor
- **id (Factor)**: The sample number from that specific irrigation event
- **block (Factor)**: Whether the sample was from tillage replication 1 or 2
- **trt (Factor)**: Designates tillage treatment, CT, MT, or ST
- **irr (Factor)**: Irrigation event number
- **tss (Numeric)**: Total suspended solids (TSS) concentration in water sample (grams/liter, g/L)
- **out (Numeric)**: Outflow runoff water volume (liters, L) for that irrigation event
- **tssl (Numeric)**: TSS load in that irrigation event (kilograms, kg)

_Note_: 
- **Date** numbers represent dates.
- **Numeric** numbers written as either integers or decimals
- **Factor** data represent distinct categories or groups.


A plot map of the agricultural field is shown below for context:
![plot map](/images/plot.png)

## Selecting Starting Values and Priors for MCMC Analysis

In Bayesian modeling, the selection of prior distributions is a critical step that reflects our prior beliefs about the parameters before any data is considered. For our MCMC analysis, we've chosen priors that are informed by expert knowledge, the scale of the parameters, and the context of our study, rather than the observed data.

### Fixed Effects
For the fixed effects in our model, we use weakly informative priors:
- **Prior**: These are set to be centered around zero, indicating no effect as a baseline, with a standard deviation that is reasonably chosen to reflect plausible effect sizes based on external knowledge or scale of the variables.
- **Rationale**: For instance, if we consider the effect sizes that are typical in similar studies or the scale of measurement, we can set a standard deviation for our priors that is broad enough to express uncertainty without being overly influenced by the data.

### Random Effects
Random effects account for variability in `yi`, `block`, and `id` in our model. The priors for these terms are chosen to reflect the expected variability between groups:

- **General Approach**:
  - **tau parameters (e.g., tau_yi, tau_block, tau_id)**: Uniform priors with bounds set based on theoretical considerations and understanding of the measurement scale, not on the observed standard deviations.

- **For `tss` and `tssl`**:
  - Priors for the `tau` parameters are set to uniform distributions with reasonable bounds that allow for flexibility in the variance components.

For each of the `u` terms, representing the random effects:
- **Priors**: Terms (`u_yi`, `u_block`, `u_id`) follow normal distributions with a mean of zero and variances informed by the tau parameters.
- **Rationale**: This reflects the expected variability and is not directly informed by the data itself.

### Residual Error (sigma)
- **Prior**: Uniform distributions with upper bounds are selected based on plausible ranges of measurement error or variability that are anticipated in the context of the field of study.
- **Rationale**: These priors are intentionally broad to not be overly restrictive and allow the data to inform the variability in the residuals.

By selecting priors in this manner, we aim to ensure that they are not informed by the dataset at hand, but rather by prior knowledge and theoretical considerations. This approach upholds the principles of Bayesian analysis, allowing the data to update our prior beliefs reflected in the posterior distributions.

## Results of Analysis
### Frequentist LMM Results
Forest plot of the frequentist LMM pairwise comparison results for `tss`:
Coming soon!

Forest plot of the frequentist LMM pairwise comparison results for `tssl`:
![frequentist](/Output/forest_plot_all_LMM.jpg)

### Bayesian LMM Results
Coming soon!

## Contribute

Contributions are always welcome! Please read the [CONTRIBUTING.md](CONTRIBUTING.md) file for details on how to contribute.

## License

This project is licensed under the GNU GPL 2.0 License. See the [LICENSE.md](LICENSE.md) file for details.

## References

- **NIMBLE Development Team. 2023.** *NIMBLE: MCMC, Particle Filtering, and Programmable Hierarchical Modeling.* doi: [10.5281/zenodo.1211190](https://doi.org/10.5281/zenodo.1211190). R package version 1.0.1, [https://cran.r-project.org/package=nimble](https://cran.r-project.org/package=nimble).
