
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

    ##                     est          se      q025      q975
    ## y5            1.2620090 0.048113115 1.1926625 1.3293857
    ## y10           1.5393466 0.100512910 1.3954679 1.6799935
    ## y25           1.8582027 0.181197731 1.6150028 2.1269925
    ## y5_gauss      1.4876568 0.089753910 1.3584606 1.6133326
    ## y10_gauss     1.8691839 0.163767828 1.6360490 2.0981297
    ## y25_gauss     2.0233749 0.239074387 1.6981301 2.3961666
    ## y5_obs        0.9879598 0.007841408 0.9756040 0.9995418
    ## y10_obs       1.0105557 0.015818030 0.9858719 1.0348578
    ## y5_gauss_obs  0.9744413 0.014242091 0.9520543 0.9953543
    ## y10_gauss_obs 0.9946831 0.026122588 0.9537895 1.0343931
