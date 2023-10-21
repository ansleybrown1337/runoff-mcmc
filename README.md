![Banner](/images/RtoPyBanner.png)
# Water Quality Data Format Converter

This repository serves as a dual-purpose tool: it not only provides utilities to convert between new and old water quality data formats used by the Colorado State University (CSU) Agricultural Water Quality Program (AWQP) but also acts as an educational resource for those interested in learning about performing the functions using both **Python** and **R** coding languages.

## Table of Contents

- [Introduction](#introduction)
- [Directory Structure](#directory-structure)
- [Getting Started](#getting-started)
- [Usage](#usage)
    - [Python](#python)
    - [R](#R)
- [Contribute](#contribute)
- [License](#license)

## Introduction

With the ever-changing nature of data standards, the need for converting between new and old formats becomes crucial and commonplace for many organizations. This repository contains scripts in both R and Python to perform an example conversion using water quality data, providing an opportunity for users to compare and contrast methodologies across two popular programming languages.

## Directory Structure

- `Code`: This directory contains all the R and Python scripts used for converting data formats.
  - `R`: Folder containing R scripts.
  - `Python`: Folder containing Python scripts.
- `Example Data`: Sample datasets in the old and new formats to help users understand the kind of data the scripts work with.
- `images`: Contains banner PNG
- `Output`: This directory is where the converted files will be saved after running the scripts.

## Getting Started

1. Clone the repository:
```bash
git clone https://github.com/your-username/water-quality-data-converter.git
cd water-quality-data-converter
```

2. If you are using Python, it's recommended to set up a virtual environment.
I personally use [VS Code](https://code.visualstudio.com/) and [Miniconda3](https://docs.conda.io/projects/miniconda/en/latest/) as my IDE.
```bash
python -m venv venv
source venv/bin/activate  # On Windows, use `venv\Scripts\activate`
pip install -r requirements.txt
```


3. For R users, make sure to install the required packages listed in the `requirements.R` file. I use [R Studio](https://posit.co/download/rstudio-desktop/) with [R](https://www.r-project.org/) as my IDE.

## Usage
> [!NOTE]  
> This is example usage at the moment, exact usage will be refined as the code is developed and finalized


### Python

Navigate to the `Code/Python` directory:

```bash
cd Code/Python
```

Run the script:

```bash
python converter.py --input "../Example Old Data/sample_old_data.csv" --output "../Output/sample_new_data.csv"
```

### R

Navigate to the `Code/R` directory:

```bash
cd Code/R
```

Run the script:

```bash
Rscript converter.R --input "../Example Old Data/sample_old_data.csv" --output "../Output/sample_new_data.csv"
```

## Contribute

Contributions are always welcome! Please read the [CONTRIBUTING.md](CONTRIBUTING.md) file for details on how to contribute.

## License

This project is licensed under the MIT License. See the [LICENSE.md](LICENSE.md) file for details.
