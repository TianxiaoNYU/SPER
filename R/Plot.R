#' Plot the spatial figures for genes / cell types
#'
#' With spatial data, coordinates and given specific feature (gene or cell type), this function plots the
#' map of this feature's spatial distribution.
#'
#' @import ggplot2
#' @param feature Specific spatial feature to plot
#' @param spatial_df A data.frame with rows as spatial spots and columns as each features
#' @param coord Spatial coordinates that match the spatial data
#' @param title.anno Annotation of the title
#' @return a ggplot2 object
#' @export
gg_gene <- function(feature,
                    spatial_df,
                    coord,
                    title.anno = "Estimated"){
  p <- ggplot() +
    geom_point(aes(x = coord$imagecol,
                   y = coord$imagerow,
                   col = spatial_df[,feature])) +
    scale_color_gradient2(low = "darkblue",
                          high = "yellow",
                          mid = "purple",
                          midpoint = max(spatial_df[,feature], na.rm = T) / 2) +
    theme_bw() +
    labs(x = "X / microns",
         y = "Y / microns",
         title = paste0(feature, " ", title.anno,  " Spatial Distribution"),
         col = feature) +
    theme(aspect.ratio = 1)
  return(p)
}


#' Visualize SPER scores of a gene/cell-type pair
#'
#' Generate a series of plots of SDGs discovered by 'findSDG': 1) the SPER curve of the indicated pair; 2) the expression level of the gene in scRNA-seq
#' reference data; 3) a spatial map showing the spatial of both the gene and the cell type is also generated.
#'
#' @import ggplot2
#' @param cell.type       Cell Type Name
#' @param gene.id         Gene ID
#' @param SPER.score      SPER score shown in the plot title
#' @param cell.thershold  Threshold for the proportion of given cell type; spots whose value larger than this
#' threshold will be marked in the spatial map
#' @param min.expr        Minimal expression value to plot (integer); only spots with given gene's expression greater than this value will be plotted
#' @param coord           Spatial coordinates for 'gg_gene'
#' @param ST.data         Spatial transcriptomics data, used for the spatial map of the gene's expression
#' @param CoDa.data       Cell-type spatial compositional data, used for the spatial map of cell-type
#' distribution
#' @param reference.data  scRNA-seq reference; should be a Seurat object
#' @param SPER.data       SPER list to plot the SPER curve
#' @param dist.list       A vector containing the list of desired distance values
#' @param plot.dir        Directory to save the plots
#' @param save.plots      Whether save plots as files or return them as objects; default is FALSE, which returns plots as objects
#' @return Null
#' @export
plotSPER <- function(cell.type,
                     gene.id,
                     SPER.score = NULL,
                     cell.thershold = 0.3,
                     min.expr = 1,
                     coord,
                     ST.data,
                     CoDa.data,
                     reference.data,
                     SPER.data,
                     dist.list,
                     plot.dir = "./Plots/",
                     save.plots = F){
  dir.create(plot.dir, showWarnings = FALSE, recursive = T)

  int_signal <- (ST.data[,gene.id] >= min.expr) + as.numeric(CoDa.data[,cell.type] > cell.thershold) * 2
  p1 <- ggplot() +
    geom_point(aes(x = coord$imagecol,
                   y = coord$imagerow,
                   col = as.factor(int_signal))) +
    theme_bw() +
    scale_color_manual(name = "Spot Class",
                       breaks = 0:3,
                       values = c("gray", "darkred", "darkblue", "purple"),
                       labels = c("Other", paste0(gene.id),
                                  paste0(cell.type, " > ", cell.thershold*100 ,"%"), "Overlap")) +
    labs(x = "X / microns",
         y = "Y / microns",
         title = paste0(gene.id, "/", cell.type,": ", SPER.score)) +
    theme(aspect.ratio = 1)

  p2 <- Seurat::VlnPlot(reference.data,
                        features = gene.id,
                        pt.size = 0.2,
                        ncol = 1)

  p3 <- ggplot() +
    geom_point(aes(x = dist.list,
                   y = SPER.data[[cell.type]][,gene.id])) +
    geom_line(aes(x = dist.list,
                  y = SPER.data[[cell.type]][,gene.id])) +
    theme_bw() +
    labs(x = "Distance / microns",
         y = "Expression Ratio",
         title = paste0(cell.type, ": ", gene.id))

  if(save.plots){
    ggsave(paste0(plot.dir, gene.id, "_", cell.type, "_", "spatial.pdf"), p1, width = 6, height = 5)
    ggsave(paste0(plot.dir, gene.id, "_", cell.type, "_", "expr.pdf"), p2, width = 8, height = 5)
    ggsave(paste0(plot.dir, gene.id, "_", cell.type, "_", "curve.pdf"), p3, width = 5, height = 4)

    return()
  }else{
    res <- list(p1, p2, p3)
    names(res) <- c(paste0(gene.id, "->", cell.type, " spatial plot"),
                    paste0(gene.id, " expression in scRNA reference"),
                    paste0(gene.id, "->", cell.type, " SPER curve"))
    return(res)
  }
}











