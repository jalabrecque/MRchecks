#' create_data
#' 
#' A function that creates simulated data to test the `MRchecks` packages.
#'
#' @param n The number of observations in the simulation.
#' @param age_range The age range of the observations.
#' @param bias A binary indicator whether the phenotype should be simulated in a way that is expected to induce bias.
#'
#' @return
#' @export
#'
#' @examples
create_data <- function(n = 10000, age_range = c(40,70), bias=TRUE, binary_outcome=FALSE) {
  
  age <- runif(n = n, min = age_range[1], max = age_range[2])
  age_scaled <- (age-min(age))/(max(age)-min(age))
  c  <- rnorm(n = n, mean = 0, sd = 0.1)
  SNP <- as.factor(rbinom(n = n, size = 2, prob = 0.3))
  if (bias) {
    y <- (SNP==0)*age_scaled*age_scaled^1.2 +
      (SNP==2)*age_scaled^0.5 + 
      (SNP==1)*age_scaled + c + rnorm(n = n, mean = 0, sd = 0.5)
  } else {
    y <- as.numeric(SNP) + age_scaled + c + rnorm(n = n, mean = 0, sd = 0.5)
  }
  
  if (binary_outcome) {
    y <- rbinom(n = n, size = 1, prob = exp(y)/(1+exp(y)))
  }

  
  return(data.frame(age,SNP,y,c))
}



