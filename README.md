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
- [Selecting Priors for MCMC Analysis](#selecting-starting-values-and-priors-for-mcmc-analysis)
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

REWRITE THIS SECTION

In Bayesian modeling, the choice of priors is fundamental as they represent our beliefs about the parameters before incorporating any data. In our MCMC analysis, we've selected our priors based on the structure of the model and insights from the observed data.

### Fixed Effects
For the fixed effects in our model, we aim to use weakly informative priors:
- **Prior**: Centered around zero with a standard deviation marginally larger than the sample standard deviation.
- **Rationale**: The sample standard deviations for `tss` and `tssl` are 0.71 mg/L and 22.15 kg, respectively. We thus selected priors that are centered around zero and have standard deviations slightly more expansive than these values.

### Random Effects
Random effects for `yi`, `block`, and `id` are integral to our model. The choice of priors for these terms is based on observed variability:

- **For `tss`:**
  - **tau_yi**: `dunif(0, 4)` based on a maximum observed SD across `yi` of 1.88.
  - **tau_block**: `dunif(0, 2)` based on a maximum observed SD across blocks of 0.787.
  - **tau_id**: `dunif(0, 2)` based on a maximum observed SD for `id` of 0.948.

- **For `tssl`:**
  - **tau_yi**: `dunif(0, 122)` given a maximum SD across `yi` of 61.1.
  - **tau_block**: `dunif(0, 45)` given a maximum SD across blocks of 22.7.
  - **tau_id**: `dunif(0, 61)` based on a maximum SD for `id` of 30.3.

For each of the `u` terms, representing the random effects:
- **Priors**: Terms (`u_yi`, `u_block`, `u_id`) are drawn from normal distributions centered at zero. Their standard deviations correspond to their respective tau values.
- **Rationale**: This captures the variability for each year (`yi`), block, and ID.

### Residual Error (sigma)
- **Prior for `tss`**: `dunif(0, 2)`
- **Prior for `tssl`**: `dunif(0, 44)` (Double the SD for `tssl`)
- **Rationale**: These are broad priors for the residual error. Setting the upper bounds as suggested allows the model to accommodate potential larger variabilities in the residuals for both `tss` and `tssl`.

## Results of Analysis
Coming Soon!

## Contribute

Contributions are always welcome! Please read the [CONTRIBUTING.md](CONTRIBUTING.md) file for details on how to contribute.

## License

This project is licensed under the GNU GPL 2.0 License. See the [LICENSE.md](LICENSE.md) file for details.

## References

- **NIMBLE Development Team. 2023.** *NIMBLE: MCMC, Particle Filtering, and Programmable Hierarchical Modeling.* doi: [10.5281/zenodo.1211190](https://doi.org/10.5281/zenodo.1211190). R package version 1.0.1, [https://cran.r-project.org/package=nimble](https://cran.r-project.org/package=nimble).
