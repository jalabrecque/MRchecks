SNPxAGE_plot <- function(SNPxAGE_model_output) {
  
  pl <- {suppressWarnings(suppressMessages(library(itsadug)))
  
  age_range <- range(SNPxAGE_model_output$model$data[SNPxAGE_model_output$params$age])
 
  pred <- get_predictions(SNPxAGE_model_output$model,list(SNP=as.factor(c(0,1,2)), age = c(round(age_range[1],0):round(age_range[2],0))))
  ylim_ <- range(c(pred$fit-pred$CI,pred$fit+pred$CI))
  
 
  par(mfrow=c(1,2))
  par(mar=c(5.1,4.1,2.1,0.1))
  
  plot_smooth(x = SNPxAGE_model_output$model, hide.label = TRUE, view = "age", 
              cond = list(SNP=as.factor(2)), lty=3, ylim=ylim_,xlim=age_range, 
              ylab=SNPxAGE_model_output$params$phenotype, xlab="Age (years)")
  plot_smooth(x = SNPxAGE_model_output$model, view = "age", cond = list(SNP=as.factor(1)), lty=2, add = TRUE,xlim=age_range)
  plot_smooth(x = SNPxAGE_model_output$model, view = "age", cond = list(SNP=as.factor(0)), lty=1, add = TRUE,xlim=age_range)

  
  ### Need to fix effects plots & plots labels
  
  # Effect plot ----
  par(mar=c(5.1,4.1,2.1,1.1))
  
  
  out <- SNPxAGE_effect(SNPxAGE_model_output,ages=c(round(age_range[1],0):round(age_range[2],0)))
  
  y_range <- range(c(0,out))
  
  pred_ages <- c(round(age_range[1],0):round(age_range[2],0))
  emptyPlot(xlim = c(round(age_range[1],0),round(age_range[2],0)), ylim = y_range, eegAxis = FALSE,
            ylab = "Per allele effect", xlab = "Age (years)")

  abline(h=0, lty=2)
  
  polygon(c(pred_ages, rev(pred_ages)),
          c(out$q025,rev(out$q975)), col=adjustcolor("grey",alpha.f=0.5),
          border=NA)
  lines(pred_ages,out$est, type = "l", lwd = 2 )}
  
  return(pl)
}