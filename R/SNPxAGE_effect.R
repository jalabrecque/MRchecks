#' Function to estimate the per-allele effect at each age
#' @export

SNPxAGE_effect <- function(SNPxAGE_output, reps=10, ages=40:70) {
  model <- SNPxAGE_output$model
  data <- model$data
  data$SNP_no_factor <- as.numeric(as.character(data$SNP))
  covars <- eval(SNPxAGE_output$params$covars)


  # Predict BMI for all ages adding in variation to give it a similar variation
  # to the original data

  sampled_params <- mgcv::rmvn(reps,coef(model),model$Vp)

  des_mat <- model.matrix(~ SNP_no_factor, data = data)

  out <- lapply(ages, function(age_) {

    data$age <- age_

    Xp <- predict(model,data,type="lpmatrix", newdata.guaranteed = TRUE)

    rep_out <- sapply(1:reps, function(r_num) {


      data$pred_pheno <- Xp %*% sampled_params[r_num,]

      lm.fit(des_mat,data$pred_pheno)$coef["SNP_no_factor"]


    })
    #print(age_)
    return(rep_out)
  }) %>% do.call(rbind,.) %>%
    apply(., 1, function(col) {
      c(mean(col),sqrt(var(col)),quantile(col, probs = c(0.025,0.975)))
    }) %>%
    t %>%
    as.data.frame %>%
    set_colnames(c("est","se","q025","q975")) %>%
    set_rownames(paste0("age_",ages))


  return(out)
}
