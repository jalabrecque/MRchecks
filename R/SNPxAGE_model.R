#' Flexibly modeling the age/phenotype association by genetic variant
#'
#' Takes a genetic variant or single nucleotide polymorphism (SNP) and a
#' phenotype it's associated with and estimates how the relationship between the
#' two varies with age using splines.
#'
#' @author Jeremy A Labrecque, \email{j.labrecque@@erasmusmc.nl}
#'
#' @param data A data frame containing the SNP, age and phenotype variables
#' @param SNP A character string with the name of the SNP variable in the data frame. This variable itself must be a factor variable containing at most 3 unique values indicating the number of copies
#' @param phenotype A character string with the name of the phenotype variable in the data frame
#' @param age A character string with the name of the age variable in the data frame
#' @param covars A character vector with the names of the variables to be adjusted for (e.g. principal components)
#' @param knots A numeric value indicating the number of internal knots (default 3)
#' @param type A character string with the type splines to be used (see `mgcv` function)
#'
#' @return A list including the model and parameters used. If pred_ages is supplied then the predictions for those ages is also returned.
#'
#' @references TBA
#'
#' @export

SNPxAGE_model <- function(data, SNP, phenotype, age, covars, k=3, pred_ages,
                          type = "cr") {

  # Setup ----------------------------------------------------------------------


  ## Assign age and SNP variabes
  data$SNP <- data[,SNP]
  data$age <- data[,age]
  data$SNP_nofactor <- as.numeric(as.character(data$SNP))

  ## Check SNP variable
  if (length(unique(data[,SNP])) > 3) stop("SNP must have a most 3 unique values")
  if (!is.factor(data$SNP)) stop("SNP variable must be a factor")

  ## Determine outcome type
  fam <- ifelse(all(na.omit(data[,phenotype]) %in% 0:1),"binomial","gaussian")


  # Run model ------------------------------------------------------------------

  if (missing(covars)) {
    mod <- mgcv::bam(formula = reformulate(termlabels = c("SNP","s(age, by = SNP, bs = type, k = k)"),
                                           response = phenotype),
                     data = data,
                     family = fam)


  } else {

    mod <- mgcv::bam(formula = reformulate(termlabels = c("SNP","s(age, by = SNP, bs = type, k = k)",covars),
                                           response = phenotype),
                     data = data,
                     family = fam)

  }

  # Return model, data and parameters ------------------------------------------


  mod$data <- data

  return(list(model = mod,
              params = as.list(match.call())))


}

