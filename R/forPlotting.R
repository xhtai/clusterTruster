# library(ggplot2)
# library(ggpubr)
# if you want to use LM Roman 10 font, run this line:
# extrafont::font_import(pattern = "lmroman*") 
my_theme <-  ggplot2::theme_bw() +
  ggplot2::theme(axis.text = ggplot2::element_text(size = 18),
                 text = ggplot2::element_text(size = 20,
                                              family="serif"), # family="LM Roman 10"),
                 plot.title = ggplot2::element_text(hjust = 0.5, size=22),
                 plot.subtitle = ggplot2::element_text(hjust = 0.5))

matlab_colors <- c(rgb(0.9290, 0.6940, 0.1250),
                   rgb(0.4940, 0.1840, 0.5560),
                   rgb(0.4660, 0.6740, 0.1880),
                   rgb(0.3010, 0.7450, 0.9330),
                   rgb(0.6350, 0.0780, 0.1840))

#' Load evaluation metrics for all possible clusters k of a given data set
#'
#' Note that the outMetrics/ folder should already be created with the associated RData created from the `getMetrics()` function
#'
#' @param datasetName name of the orginal data set
#' @return data set with the following fields: `numClusters` `maxMinimax`  `misClass` `precision` `recall`  `Linkage`
#' @export
loadDataset <- function(datasetName) {
  load(paste0("./outMetrics/", datasetName, "_single.Rdata"))
  dat <- cbind(outMetrics,
               Linkage = "single")
  
  linkages <- c("single", "complete", "average", "centroid", "minimax")
  for (i in 2:length(linkages)) {
    load(paste0("./outMetrics/", datasetName, "_", linkages[i], ".Rdata"))
    dat <- rbind(dat,
                 cbind(outMetrics,
                       Linkage = linkages[i]))
  }
  return(dat)
}

#' Create evaluation ggplot graphics for linkage results
#'
#' @param datasetName name of the orginal data set; to use this parameter you must have a folder called "outMetrics/", with files for each linkage method of the format: "datasetName_single.Rdata"
#' @param correlation if TRUE, set y limits in max minimax graphic to be [0, 1]
#' @param write_plot if TRUE, write the graph to the working directory using ggsave()
#' @param plot_type which evaluation graph you want to produce
#' 
#' @return evaluation graph, as specified in plot_type
#' @export
plotResultsGG <- function(datasetName,
                          correlation=FALSE,
                          write_plot=FALSE, 
                          plot_type = c("all", "minimax", "misclass", "pr")) {
  dat <- loadDataset(datasetName)
  
  plot_maxMinimax <- 
    ggplot2::ggplot(dat) + 
    ggplot2::geom_line(ggplot2::aes(numClusters, maxMinimax,
                                    color = Linkage),
                       size = 1.2) +
    my_theme + 
    ggplot2::labs(x = "Number of clusters",
                  y = "\nMaximum minimax radius",
                  title = "Minimax Radius") + 
    ggplot2::scale_color_manual(values = matlab_colors) 
  
  plot_maxMinimax <- if(correlation){
    plot_maxMinimax + ggplot2::ylim(c(0, 1))
  } else{
    plot_maxMinimax
  }

  plot_misclass <- 
    ggplot2::ggplot(dat) + 
    ggplot2::geom_line(ggplot2::aes(numClusters, misClass, color = Linkage),
                       size = 1.2) +
    my_theme + 
    ggplot2::labs(x = "Number of clusters",
                  y = "\nMisclassification rate",
                  title = "Misclassification") + 
    ggplot2::scale_color_manual(values = matlab_colors) + 
    ggplot2::ylim(c(0, 1))
  
  plot_pr <- 
    ggplot2::ggplot(dat) + 
    ggplot2::geom_path(ggplot2::aes(recall, precision, 
                                    color = Linkage),
                       size = 1.2) +
    my_theme + 
    ggplot2::labs(x = "Recall",
                  y = "\nPrecision",
                  title = "Precision-Recall") + 
    ggplot2::scale_color_manual(values = matlab_colors) + 
    ggplot2::xlim(c(0, 1)) + 
    ggplot2::ylim(c(0, 1))
  
  if(plot_type == "all"){
    if(write_plot){
      ggpubr::ggarrange(plot_maxMinimax, plot_misclass, plot_pr,
                        ncol=3, nrow=1,
                        common.legend = TRUE, legend="bottom") %>%
        ggplot2::ggsave(paste0("./paper/figs/", datasetName, "GG.png"), .,
                        width = 14, height = 4)
    } else{
      ggpubr::ggarrange(plot_maxMinimax, plot_misclass, plot_pr,
                        ncol=3, nrow=1, 
                        common.legend = TRUE, legend="bottom") 
    }
  } else if(plot_type == "minimax"){
    plot_maxMinimax 
  } else if(plot_type == "misclass"){
    plot_misclass
  } else{
    plot_pr
  }
}


#' Create evaluation ggplot graphics for varying linkage results
#'
#' @param single name of of preloaded outmetrics for single linkage
#' @param complete name of of preloaded outmetrics for complete linkage
#' @param average name of of preloaded outmetrics for average linkage
#' @param centroid name of of preloaded outmetrics for centroid linkage
#' @param minimax name of of preloaded outmetrics for minimax linkage
#' @param correlation if TRUE, set y limits in max minimax graphic to be [0, 1]
#' @param write_plot if TRUE, write the graph to the working directory using ggsave()
#' @param plot_type which evaluation graph you want to produce
#' 
#' @return evaluation graph, as specified in plot_type
#' @export
plotResultsGG_base <- function(single = NULL,
                               complete = NULL,
                               average = NULL,
                               centroid = NULL,
                               minimax = NULL,
                               correlation=FALSE,
                               write_plot=FALSE, 
                               plot_type = c("all", "minimax", "misclass", "pr")) {
  
  linkages <- c("single", "complete", "average", "centroid", "minimax")
  
  dat <- c()
  
  if(!is.null(single)){
    dat <- rbind(dat, 
                 cbind(single,
                       Linkage = "single"))
  }
  if(!is.null(complete)){
    dat <- rbind(dat, 
                 cbind(complete,
                       Linkage = "complete"))
  }
  if(!is.null(average)){
    dat <- rbind(dat, 
                 cbind(average,
                       Linkage = "average"))
  }
  if(!is.null(centroid)){
    dat <- rbind(dat, 
                 cbind(centroid,
                       Linkage = "centroid"))
  }
  if(!is.null(minimax)){
    dat <- rbind(dat, 
                 cbind(single,
                       Linkage = "single"))
  }
  
  plot_maxMinimax <- 
    ggplot2::ggplot(dat) + 
    ggplot2::geom_line(ggplot2::aes(numClusters, maxMinimax,
                                    color = Linkage),
                       size = 1.2) +
    my_theme + 
    ggplot2::labs(x = "Number of clusters",
                  y = "\nMaximum minimax radius",
                  title = "Minimax Radius") + 
    ggplot2::scale_color_manual(values = matlab_colors) 
  
  plot_maxMinimax <- if(correlation){
    plot_maxMinimax + ggplot2::ylim(c(0, 1))
  } else{
    plot_maxMinimax
  }
  
  plot_misclass <- 
    ggplot2::ggplot(dat) + 
    ggplot2::geom_line(ggplot2::aes(numClusters, misClass, color = Linkage),
                       size = 1.2) +
    my_theme + 
    ggplot2::labs(x = "Number of clusters",
                  y = "\nMisclassification rate",
                  title = "Misclassification") + 
    ggplot2::scale_color_manual(values = matlab_colors) + 
    ggplot2::ylim(c(0, 1))
  
  plot_pr <- 
    ggplot2::ggplot(dat) + 
    ggplot2::geom_path(ggplot2::aes(recall, precision, 
                                    color = Linkage),
                       size = 1.2) +
    my_theme + 
    ggplot2::labs(x = "Recall",
                  y = "\nPrecision",
                  title = "Precision-Recall") + 
    ggplot2::scale_color_manual(values = matlab_colors) + 
    ggplot2::xlim(c(0, 1)) + 
    ggplot2::ylim(c(0, 1))
  
  if(plot_type == "all"){
    if(write_plot){
      ggpubr::ggarrange(plot_maxMinimax, plot_misclass, plot_pr,
                        ncol=3, nrow=1,
                        common.legend = TRUE, legend="bottom") %>%
        ggplot2::ggsave(paste0("./paper/figs/", datasetName, "GG.png"), .,
                        width = 14, height = 4)
    } else{
      ggpubr::ggarrange(plot_maxMinimax, plot_misclass, plot_pr,
                        ncol=3, nrow=1, 
                        common.legend = TRUE, legend="bottom") 
    }
  } else if(plot_type == "minimax"){
    plot_maxMinimax 
  } else if(plot_type == "misclass"){
    plot_misclass
  } else{
    plot_pr
  }
}