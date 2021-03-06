#' Estimate bias from age-varying genetic effects in Mendelian randomization
#'
#' Takes output from \code{SNPxAGE_model} and estimates the bias due to
#' age-varying genetic effects under different exposure windows and at two
#' different ages
#'
#' @param SNPxAGE_model_output Output from \code{SNPxAGE_model}
#' @param rep Numerical value of the number of iterations to run the simulations
#'
#' @return A list of results
#'
#' @export
#'
#' @examples
#'
#'
#'



SNPxAGE_bias <- function(SNPxAGE_model_output, rep = 2, age_set = 65) {

  # Set up ---------------------------------------------------------------------

  model <- SNPxAGE_model_output$model
  data <- model$data
  covars <- eval(SNPxAGE_model_output$params$covars)
  data$age <- round(data$age,0)
  age_range <- range(data$age)
  if (missing(age_set)) age_set <- age_range[2]
  age_range_width <- diff(age_range)
  age_range_set <- age_set - age_range[1]
  if (age_range_set<5) stop("Not enough range in age (minimum 5 years)")


  # Predict BMI for all ages ---------------------------------------------------

  ## Sample from parameter distributions from model
  sampled_params <- mgcv::rmvn(rep,coef(model),model$Vp)

  ## At a specific age

  ## Exposure windows at age 65 (number = width of window in years, l = linear, g = gaussian)
  y_window_5l <- seq(0,1, length.out = 5 + 1)[-1]
  y_window_10l <- seq(0,1, length.out = 10 + 1)[-1]
  y_window_25l <- seq(0,1, length.out = 25 + 1)[-1]
  y_window_5g <- dnorm((age_range[1]-age_set+5):5,mean = 2.5, sd = 1.2473)
  y_window_10g <- dnorm((age_range[1]-age_set+10):10,mean = 5, sd = 2.734)
  y_window_25g <- dnorm((age_range[1]-age_set+25):25,mean = 12.5, sd = 6.3775)

  if (age_range_set>25) {
    outcomes <- c("y5","y10","y25","y5_gauss","y10_gauss","y25_gauss")
  } else if (age_range_set>=10) {
    outcomes <- c("y5","y10","y5_gauss","y10_gauss")
  } else {
    outcomes <- c("y5","y5_gauss")
}

  if (age_range_width>10) {
    outcomes_obs <- c("y5_obs","y10_obs","y5_gauss_obs","y10_gauss_obs")
  } else {
    outcomes_obs <- c("y5_obs","y5_gauss_obs")
  }


  # Apply over the 1000 sampled sets of parameters
  out_sam <- lapply(1:rep, FUN = function(set_params) {

    d_rep <- cbind(data, setNames(
      # Apply over ages
      lapply(age_range[1]:age_set, function(x) {

        Xp <- predict(model,transform(data, age = x),type="lpmatrix", newdata.guaranteed = TRUE)

        return(Xp %*% sampled_params[set_params,])
      }),
      paste0("pred_",age_range[1]:age_set))
    )

    # Applying exposure windows at age 65
    d_rep$y5 <- (as.matrix(dplyr::select(d_rep,paste0("pred_",(age_set-4):age_set))) %*% y_window_5l)/3
    if (age_range_width>=10) d_rep$y10 <- (as.matrix(dplyr::select(d_rep,paste0("pred_",(age_set-9):age_set))) %*% y_window_10l)/5.5
    if (age_range_width>=25) d_rep$y25 <- (as.matrix(dplyr::select(d_rep,paste0("pred_",(age_set-24):age_set))) %*% y_window_25l)/13
    d_rep$y5_gauss <- (as.matrix(dplyr::select(d_rep,paste0("pred_",age_range[1]:age_set))) %*% y_window_5g)/0.993
    if (age_range_width>=10) d_rep$y10_gauss <- (as.matrix(dplyr::select(d_rep,paste0("pred_",age_range[1]:age_set))) %*% y_window_10g)/0.978
    if (age_range_width>=25) d_rep$y25_gauss <- (as.matrix(dplyr::select(d_rep,paste0("pred_",age_range[1]:age_set))) %*% y_window_25g)/0.9573


    # Applying exposure windows at observed age
    d_rep_obs <- lapply(unique(d_rep$age)[unique(d_rep$age)<=age_set], function(a) {

      ds_temp <- d_rep[d_rep$age==a,]

      if (a < (age_range[1]+4)) {
        ds_temp$y5_obs <- NA
        ds_temp$y10_obs <- NA
        ds_temp$y5_gauss_obs <- NA
        ds_temp$y10_gauss_obs <- NA
      } else if (a < (age_range[1]+9) & a >=(age_range[1]+4)) {
        ds_temp$y5_obs <- (as.matrix(dplyr::select(ds_temp,paste0("pred_",c((a-4):a)))) %*% y_window_5l)/3
        ds_temp$y10_obs <- NA
        ds_temp$y5_gauss_obs <- (as.matrix(dplyr::select(ds_temp,paste0("pred_",c((a-4):a)))) %*% tail(y_window_5g,5))/0.94355
        ds_temp$y10_gauss_obs <- NA
      } else {
        ds_temp$y5_obs <- (as.matrix(dplyr::select(ds_temp,paste0("pred_",c((a-4):a)))) %*% y_window_5l)/3
        if (age_range_width>=10) ds_temp$y10_obs <- (as.matrix(dplyr::select(ds_temp,paste0("pred_",c((a-9):a)))) %*% y_window_10l)/5.5
        ds_temp$y5_gauss_obs <- (as.matrix(dplyr::select(ds_temp,paste0("pred_",c((a-4):a)))) %*% tail(y_window_5g,5))/0.94355
        if (age_range_width>=10) ds_temp$y10_gauss_obs <- (as.matrix(dplyr::select(ds_temp,paste0("pred_",c((a-9):a)))) %*% tail(y_window_10g,10))/0.9295
      }

      ds_temp$pred_obs <- ds_temp[,paste0("pred_",a)]

      return(ds_temp)


    }) %>% do.call(rbind,.) %>% as.data.frame




    # Estimation==================================================================
    d_rep$SNP_no_factor <- as.numeric(d_rep$SNP)

    out <- lapply(outcomes, FUN = function(scen) {
      summary(AER::ivreg(as.formula(paste0(scen," ~ ",
                                             paste0("pred_",age_set),
                                             " | SNP_no_factor")),
                           data = d_rep))$coef[paste0("pred_",age_set),c("Estimate")]
    }) %>%
      unlist %>%
      magrittr::set_names(outcomes)

    # Observed age
    d_rep_obs$SNP_no_factor <- as.numeric(d_rep_obs$SNP)

    out_obs <- lapply(outcomes_obs, FUN = function(scen) {
      summary(AER::ivreg(as.formula(paste0(scen," ~ ",
                                      "pred_obs",
                                      " | SNP_no_factor")),
                    data = d_rep_obs))$coef["pred_obs",c("Estimate")]
    }) %>%
      unlist %>%
      magrittr::set_names(outcomes_obs)





    return(c(out,out_obs))

  }) %>%
    do.call(rbind,.)


  output <- apply(out_sam, 2, FUN = function(param) {
    return(c(mean(param),sqrt(var(param)), quantile(x = param, probs = c(0.025,0.975))))
  }) %>%
    t %>%
    magrittr::set_colnames(c("est","se","q025","q975")) %>%
    magrittr::set_rownames(c(outcomes,outcomes_obs))

  return(output)



}
