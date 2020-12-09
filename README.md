
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
