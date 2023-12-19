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
- [Methodology](#methodology)
- [Results and Discussion](#results-and-discussion)
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


4. Execute the R script. This will initiate the MCMC process and might take some time, depending on the dataset's size and the number of iterations.

5. Once the script completes, you'll be able to see the model's results, including any plots or graphs generated.

## Methodology
### Data Structure and Experimental Design

#### **Data Structure**

The example data provided is runoff water sediment concentration and load measured from a surface-irrigated, agricultural research field with various tillage treatments from 2011 - 2016.

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

#### **Experimental Design**

A plot map of the agricultural field is shown below for context:
![plot map](/images/plot.png)

### Data Analysis

For this project, I will be using the work flow outlined by Dr. Richard McElreath in his book, [Statistical Rethinking](https://xcelab.net/rm/statistical-rethinking/). This flow is as follows, stated in [Chapter 4, Geocentric Models](https://www.youtube.com/watch?v=tNOu-SEacNU&list=PLDcUM9US4XdPz-KxHM4XHt7uUVGWWVSus&index=3):
1. State a clear question
2. Sketch your causal assumptions
3. Use the sketch to build a generative model
4. Use the model to build estimator
5. Profit

#### 1. State a clear question
**What is the effect of tillage treatment on total suspended solids (TSS) load in runoff water, considering the effects of all other relevant variables?**

#### 2. Sketch your causal assumptions
The second step in our analysis is to define the causal model of our system, which can be represented as a directed acyclic graph (DAG) that represents the causal relationships between the variables in our model. 

![DAG](/images/dagitty-model.jpeg)

The OWL is defined using the [DAGitty](http://dagitty.net/) package in R.

This DAG shows us that the variables `trt` is our exposure variable, or the variable where causal effects are the primary interest. Variables `irr`, `year`, and `block` are variables also associated with the outcome, `tssl` or tss load. The model implies the following conditional independences:

trt ⊥ irr <br/>
trt ⊥ year <br/>
trt ⊥ block <br/>
irr ⊥ year <br/>
irr ⊥ block <br/>
year ⊥ block 


The conditional independences can be listed as:

- `trt` is independent of `irr`, `year`, and `block`.
- `irr` is independent of `trt`, `year`, and `block`.
- `year` is independent of `trt`, `irr`, and `block`.
- `block` is independent of `trt`, `irr`, and `year`

#### 3. Use the sketch to build a generative model

The linear mixed model with these independences is formulated as:

$$
TSSLoad = \beta_0 + \beta_1 \times trt + \beta_2 \times irr + \beta_3 \times year + u_{\text{block}} + \epsilon
$$

In this model:

- $TSSLoad$ is the dependent variable.
- $trt$, $irr$, and $year$ are the fixed effects, with $\beta_1$, $\beta_2$, and $\beta_3$ as their respective coefficients.
- $\beta_0$ is the intercept.
- $u_{\text{block}}$ represents the random effect associated with `block`. This term captures the variability in $TSSLoad$ attributable to different levels of `block`. It's assumed that $u_{\text{block}}$ is normally distributed with a mean of 0 and some variance $\sigma^2_{\text{block}}$.
- $\epsilon$ is the residual error term, capturing the variability in $TSSLoad$ not explained by the model. It's typically assumed to be normally distributed with a mean of 0 and variance $\sigma^2$.


**Selecting Starting Values and Priors**

In Bayesian modeling, the selection of prior distributions is a critical step that reflects our prior beliefs about the parameters before any data is considered.

*Fixed Effects* <br>
For the fixed effects in our model, we use weakly informative priors:
- **Prior**: 
- **Rationale**: 

*Random Effects* <br>
Random effects account for variability in `block` in our model. The priors for these terms are chosen to reflect the expected variability between groups:

- **General Approach**:
  - **tau parameters (e.g., tau_block)**: Uniform prior with bounds set based on theoretical considerations and understanding of the measurement scale, not on the observed standard deviations.

- **For `tss` and `tssl`**:
  - Priors for the `tau` parameters are set to uniform distributions with reasonable bounds that allow for flexibility in the variance components.

For each of the `u` terms, representing the random effects:
- **Priors**: Terms (`u_yi`, `u_block`, `u_id`) follow normal distributions with a mean of zero and variances informed by the tau parameters.
- **Rationale**: This reflects the expected variability and is not directly informed by the data itself.

*Sigma*
- **Prior**: 
- **Rationale**: 

By selecting priors in this manner, we aim to ensure that they are not informed by the dataset at hand, but rather by prior knowledge and theoretical considerations. This approach upholds the principles of Bayesian analysis, allowing the data to update our prior beliefs reflected in the posterior distributions.

## Results and Discussion
### Bayesian LMM Results
Coming soon!
#### **Model Convergence**
*Trace and marginal density plots*

We can check the convergence of our model by looking at the trace plots of the MCMC chains for each parameter. If the chains are well-mixed and stationary, it suggests that the model has converged and the MCMC algorithm has sampled the posterior distribution well.

- [Click here to see the trace plots for the model parameters](Output/trace_density_plots.pdf)

You can see in the trace plots that the chains are well-mixed and stationary, and the posterior distributions are well-sampled overall.

*Correlation plots*

Additionaly, we may want to investigate correlation between variables.  The `correlationPlot()` function in the `BayesianTools` package can be used to visualize the correlation between variables in the MCMC chains:

![Correlation Plot](Output/correlation_plots.png)

*Gelman chain convergence*

Thirdly, we will also check how two chains from the same NIMBLE model converged using the `gelman.diag()` and `gelman.plot()` functions as found in the `BayesianTools` package:

```r
```

The `gelman.diag()` function gives you the scale reduction factors for each parameter. A factor of 1 means that between variance and within chain variance are equal, larger values mean that there is still a notable difference between chains. Often, it is said that everything below 1.1 or so is OK, but note that this is more a rule of thumb. 

The `gelman,plot()` function shows you the development of the scale-reduction over time (chain steps), which is useful to see whether a low chain reduction is also stable (sometimes, the factors go down and then up again, as you will see). The gelman plot is also a nice tool to see roughly where this point is, that is, from which point on the chains seem roughly converged. You can see that both chains converge to eachother around the value of zero after the 10,000 iterations mark. This is a good sign that our model has converged.

*Posterior predictive checks*

Finally, we would like to do the posterior predictive checks for the NIMBLE model to see how it captures TSS error overall. Using a NIMBLE function to generate simulated TSS error, we will compare resulting simulated mean , median, min and max value distributions to the observed TSS error summary statistic:

![Posterior Predictive Check](Output/posterior_pred_plots.png)

*Summary of convergence*

Considering all of the above, that is, the trace plots, correlation plots, and gelman plots, we can conclude that our model has converged and the MCMC algorithm has sampled the posterior distribution well.

#### **Posterior Comparison Results**
Coming soon!

### Frequentist LMM Results
Coming soon!

## Contribute

Contributions are always welcome! Please read the [CONTRIBUTING.md](CONTRIBUTING.md) file for details on how to contribute.

## License

This project is licensed under the GNU GPL 2.0 License. See the [LICENSE.md](LICENSE.md) file for details.

## References

- **NIMBLE Development Team. 2023.** *NIMBLE: MCMC, Particle Filtering, and Programmable Hierarchical Modeling.* doi: [10.5281/zenodo.1211190](https://doi.org/10.5281/zenodo.1211190). R package version 1.0.1, [https://cran.r-project.org/package=nimble](https://cran.r-project.org/package=nimble).

---
**[Return to Top](#table-of-contents)**