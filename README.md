
# MRchecks

## Overview

`MRchecks` is a package that performs all the analyses in a forthcoming
paper on how time-varying exposures can bias Mendelian randomization
(MR) analyses. The theory behind this paper can be found in:
[Interpretation and Potential Biases of Mendelian Randomization
Estimates With Time-Varying
Exposures](https://pubmed.ncbi.nlm.nih.gov/30239571/). With the
functions in this package you can graph and estimate how the association
of a genetic variant with a phenotype changes with age. If you’re
concerned that the association changes enough that it may bias your MR
estimate, there is also a function that will estimate the potential bias
under a number of exposure windows.

## Installation

Installation requires devtools which can be installed with
`install.packages("devtools")`. Once you have `devtools` installed you
can install MRchecks with:

``` r
devtools::install_github("jalabrecque/MRchecks")
```

## Usage

The package comes with a small test data set called `test_data`:

``` r
library(MRchecks)
data(test_data)
```

The data set contains the minimal variables required:

``` r
head(test_data)
```

    ##        age SNP           y           c
    ## 1 54.52100   0 -0.07573056  0.04497838
    ## 2 52.78986   0  0.10594687 -0.02224538
    ## 3 57.25049   2  0.23805736  0.05457459
    ## 4 62.60263   0  1.33247060  0.10780435
    ## 5 65.62173   1  1.08230059  0.22915236
    ## 6 69.62285   1  0.74436273 -0.24542123

An age variable (age), a factor variable with the genetic data (SNP) a
phenotype that will be used as the exposure in the MR analysis (y) and
here, optionally, a covariate is included (c).

### Run model

We can first use the `SNPxAGE_model` function to fit the model we will
use as the input for the other functions:

``` r
SNPxAGE_model_output <- SNPxAGE_model(data = test_data,
                                      SNP = "SNP",
                                      phenotype = "y",
                                      age = "age",
                                      k = 3,
                                      covars="c")
```

The argument k specifies how many internal knots should be used.

### Plotting age-varying genetic associations

We can plot the relationship between age and the phenotype by genetic
variant as well as a plot of additive genetic effects by age:

``` r
SNPxAGE_plot(SNPxAGE_model_output)
```

![](README_files/figure-gfm/unnamed-chunk-4-1.png)<!-- -->

    ## NULL

### Plasmode simulation for potential bias

Looking at the output of this plot we might be concerned that the
genetic association with the phenotype varies enough that bias is a real
concern. Using `SNPxAGE_bias` we can check what the bias would be if all
the MR assumptions hold:

``` r
SNPxAGE_bias(SNPxAGE_model_output,rep = 10,age_set = 66)
```

    ##                     est         se      q025      q975
    ## y5            1.2854790 0.07355369 1.2101393 1.4323854
    ## y10           1.5886760 0.15392067 1.4310885 1.8962119
    ## y25           1.9495376 0.27757375 1.6671904 2.5036913
    ## y5_gauss      1.5314936 0.13726263 1.3909089 1.8056666
    ## y10_gauss     1.9498922 0.25103518 1.6929833 2.4515638
    ## y25_gauss     2.1442806 0.36226372 1.7738778 2.8646884
    ## y5_obs        0.9901961 0.00689649 0.9794219 1.0005172
    ## y10_obs       1.0157585 0.01543451 0.9931396 1.0408538
    ## y5_gauss_obs  0.9784067 0.01237369 0.9589676 0.9967018
    ## y10_gauss_obs 1.0027975 0.02457611 0.9658367 1.0416799

The output lists an estimate for the bias, standard error as well as
2.5% and 97.5% percentile of the bias over the amount of runs listed in
rep. The row names indicate which exposure window was used. The number
indicates the length of the exposure window. Rows with gauss use a
gaussian exposure window and those without use a linear, increasing
exposure window. The suffix obs indicates that the exposure was set
relative to the age at which the individual was observed in the dataset.
