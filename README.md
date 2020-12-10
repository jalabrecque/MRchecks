
# MRchecks

## Overview

`MRchecks` is a package that performs all the analyses in a forthcoming
paper on how time-varying exposures can bias Mendelian randomization
(MR) analyses. With the functions in this package you can graph and
estimate how the association of a genetic variant with a phenotype
changes with age. If you’re concerned that the association changes
enough that it may bias your MR estimate, there is also a function that
will estimate the potential bias under a number of exposure windows.

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

We can plot the relationship between age and the phenotype by genetic
variant as well as a plot of additive genetic effects by age:

``` r
SNPxAGE_plot(SNPxAGE_model_output)
```

![](README_files/figure-gfm/unnamed-chunk-4-1.png)<!-- -->

    ## NULL

Looking at the output of this plot we might be concerned that the
genetic association with the phenotype varies enough that bias is a real
concern. Using `SNPxAGE_bias` we can check what the bias would be if all
the MR assumptions hold:

``` r
SNPxAGE_bias(SNPxAGE_model_output,rep = 10,age_set = 65)
```

    ##                     est          se      q025      q975
    ## iv_den65      0.1329657 0.012541315 0.1152439 0.1532160
    ## iv_avg        0.1837739 0.000000000 0.1837739 0.1837739
    ## y5            1.2189263 0.025780500 1.1749198 1.2545551
    ## y10           1.4421353 0.053563818 1.3500020 1.5154541
    ## y5_gauss      1.4058310 0.048023552 1.3237258 1.4720777
    ## y10_gauss     1.7030539 0.087014568 1.5526164 1.8212497
    ## iv_den_obs    0.2045320 0.010761181 0.1866217 0.2194067
    ## y5_obs        0.9826433 0.006073999 0.9727345 0.9915667
    ## y10_obs       0.9987936 0.012410744 0.9782858 1.0162473
    ## y5_gauss_obs  0.9647925 0.010975542 0.9470084 0.9810112
    ## y10_gauss_obs 0.9751037 0.020266486 0.9420648 1.0042850
