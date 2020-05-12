
<!-- README.md is generated from README.Rmd. Please edit that file -->

# clusterTruster

This is a package to benchmark linkages in hierarchical clustering.
Please see our paper on arXiv for more detailed examples:
<https://arxiv.org/abs/1906.03336>. The authors of the paper and this
package are Xiao Hui Tai (<https://xhtai.github.io/>) and Kayla Frisoli
(<http://stat.cmu.edu/~kfrisoli/>).

## Installation

You can install `clusterTruster` from github with:

``` r
devtools::install_github("xhtai/clusterTruster")
library(clusterTruster)
```

## Examples

### iris

We can analyze the iris data set as follows. We first center and scale
the four features, “Sepal.Length”, “Sepal.Width”, “Petal.Length”,
“Petal.Width”, and generate the l2 distance between all pairs. We then
use various linkage methods to generate all associated evaluation
metrics.

``` r
myPairwise <- clusterTruster::genPairwise(iris, 5)
iris[, 1:4] <- scale(iris[, 1:4])
myPairwise <-
  clusterTruster::genSimDiff(iris, 1:4, myPairwise, 1:2, "l2dist")
```

``` r
outMetrics_iris_single <- clusterTruster::getMetrics(
  myPairwise,
  pairColNums = 1:2,
  matchColNum = 3,
  distSimCol = "l2dist",
  linkage = "single"
)
#> 10 , 20 , 30 , 40 , 50 , 60 , 70 , 80 , 90 , 100 , 110 , 120 , 130 , 140 , 150 ,
outMetrics_iris_complete <- clusterTruster::getMetrics(
  myPairwise,
  pairColNums = 1:2,
  matchColNum = 3,
  distSimCol = "l2dist",
  linkage = "complete"
)
#> 10 , 20 , 30 , 40 , 50 , 60 , 70 , 80 , 90 , 100 , 110 , 120 , 130 , 140 , 150 ,
outMetrics_iris_average <- clusterTruster::getMetrics(
  myPairwise,
  pairColNums = 1:2,
  matchColNum = 3,
  distSimCol = "l2dist",
  linkage = "average"
)
#> 10 , 20 , 30 , 40 , 50 , 60 , 70 , 80 , 90 , 100 , 110 , 120 , 130 , 140 , 150 ,
outMetrics_iris_centroid <- clusterTruster::getMetrics(
  myPairwise,
  pairColNums = 1:2,
  matchColNum = 3,
  distSimCol = "l2dist",
  linkage = "centroid"
)
#> 10 , 20 , 30 , 40 , 50 , 60 , 70 , 80 , 90 , 100 , 110 , 120 , 130 , 140 , 150 ,
outMetrics_iris_minimax <- clusterTruster::getMetrics(
  myPairwise,
  pairColNums = 1:2,
  matchColNum = 3,
  distSimCol = "l2dist",
  linkage = "minimax"
)
#> 10 , 20 , 30 , 40 , 50 , 60 , 70 , 80 , 90 , 100 , 110 , 120 , 130 , 140 , 150 ,
```

#### Plotting linkage method results for iris

To compare single, complete, and average:

``` r
clusterTruster::plotResultsGG_base(
  single = outMetrics_iris_single,
  complete = outMetrics_iris_complete,
  average = outMetrics_iris_average,
  correlation = FALSE,
  write_plot = FALSE,
  plot_type = c("all", "minimax", "misclass", "pr")
)
```

<img src="README-unnamed-chunk-4-1.png" style="display: block; margin: auto;" />

To compare all:

``` r
clusterTruster::plotResultsGG_base(
  single = outMetrics_iris_single,
  complete = outMetrics_iris_complete,
  average = outMetrics_iris_average,
  centroid = outMetrics_iris_centroid,
  minimax = outMetrics_iris_minimax,
  correlation = FALSE,
  write_plot = FALSE,
  plot_type = c("all", "minimax", "misclass", "pr")
)
```

<img src="README-unnamed-chunk-5-1.png" style="display: block; margin: auto;" />

# Reproducing Paper Results

### NBIDE

The package also contains an example data set, called `removedDups`.
This analyzes 144 images of cartridge cases, taken from NIST’s
[Ballistics Toolmarks Research Database](https://tsapps.nist.gov/NRBTD).
There are 12 images each taken from 12 different guns, from the NBIDE
study. Pairwise comparisons have been pre-computed using the
[`cartridges3D` package](https://github.com/xhtai/cartridges3D), and
stored in `removedDups`. In this case, we do not need to use the
functions `genPairwise()` or `genSimDiff()`, and can simply input the
appropriate data and column information into `getMetrics`, as follows.

``` r
NBIDEminimax <- getMetrics(removedDups, pairColNums = 1:2, 
                           matchColNum = "match", distSimCol = "corrMax",
                           linkage = "minimax", myDist = FALSE) 
```

## Creating outMetrics/ folder

## Plots

This is some example code for generating plots, assuming that metrics
have been generated using each linkage method and stored in a Rdata
files with their corresponding names. I have a folder called
`outMetrics/` with the following contents: `faces_average.Rdata`,
`faces_centroid.Rdata`, `faces_complete.Rdata`, `faces_minimax.Rdata`,
`faces_single.Rdata`

``` r
plotResultsGG("faces", plot_type = "minimax")
plotResultsGG("faces", plot_type = "misclass")
plotResultsGG("faces", plot_type = "pr")
plotResultsGG("faces", write_plot = FALSE, plot_type = "all")
```

For the following, I would need to have `outMetrics/` with the following
contents: `NBIDE_average.Rdata`, `NBIDE_centroid.Rdata`,
`NBIDE_complete.Rdata`, `NBIDE_minimax.Rdata`,
`NBIDE_single.Rdata`

``` r
plotResultsGG("NBIDE", correlation = TRUE, write_plot = FALSE, plot_type = "all")
```

## License

The `clusterTruster` package is licensed under GPLv3
(<http://www.gnu.org/licenses/gpl.html>).
