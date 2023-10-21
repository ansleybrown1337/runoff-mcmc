![Banner](/images/banner.png)
# Modeling Runoff Water Quality using Markov-Chain Monte Carlo Techniques in R

Here, we explore the application of Markov-Chain Monte Carlo (MCMC) techniques to model runoff water quality. This project signifies my inaugural venture into leveraging MCMC methodologies, aiming to provide a deeper understanding and predictive capabilities for runoff water quality.

## Key Features:
- **Programming Language:** R
- **Key Package:** NIMBLE
- **Technique:** Markov-Chain Monte Carlo (MCMC)

The repository is structured to guide you through the entire process, from data preprocessing to model evaluation. Whether you're an environmental scientist, a data analyst, or someone with a keen interest in water quality modeling, this repository offers insights into the potential of MCMC techniques in the field.

Feel free to explore the code, datasets, and documentation. Your contributions, feedback, and suggestions are always appreciated!


## Table of Contents

- [Directory Structure](#directory-structure)
- [Getting Started](#getting-started)
- [Running the Model](#running-the-model)
- [Contribute](#contribute)
- [License](#license)

## Directory Structure

- `Code`: This directory contains the R code for analysis.
- `Example Data`: Sample dataset that I'm using to test my analysis.
- `images`: Contains banner image.
- `Output`: Where output images and results will be saved.

## Getting Started

1. Clone the repository:
```bash
git clone https://github.com/your-username/water-quality-data-converter.git
cd water-quality-data-converter
```

2. Open the R code in the repository using an IDE like Rstudio or VS code.

3. Install NIMBLE.
> [!IMPORTANT]  
> Before installing NIMBLE, you need a compiler and related tools such as make that R can use. For Windows users, this is [Rtools](http://cran.r-project.org/bin/windows/Rtools), and for Mac users it is [Xcode](https://mac.install.guide/commandlinetools/4.html#:~:text=Use%20'xcode%2Dselect'%20to%20install%20Xcode%20Command%20Line%20Tools&text=The%20command%20xcode%2Dselect%20%2D%2Dinstall%20will%20open%20a%20dialog,of%20the%20command%20line%20tools.&text=You'll%20see%20a%20panel,the%20download%20and%20installation%20process.).

## Running the Model
1. **Load the Dataset:** Ensure the dataset is in the correct path or adjust the path in the script accordingly.

2. **Run the Script:** Execute the R script. This will initiate the MCMC process and might take some time, depending on the dataset's size and the number of iterations.

3. **View the Results:** Once the script completes, you'll be able to see the model's results, including any plots or graphs generated.
## Contribute

Contributions are always welcome! Please read the [CONTRIBUTING.md](CONTRIBUTING.md) file for details on how to contribute.

## License

This project is licensed under the GNU GPL 2.0 License. See the [LICENSE.md](LICENSE.md) file for details.
