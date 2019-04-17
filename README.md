
<!-- README.md is generated from README.Rmd. Please edit that file -->
clusterTruster
==============

This is a package to benchmark linkages in hierarchical clustering.

Installation
------------

You can install `clusterTruster` from github with:

``` r
devtools::install_github("xhtai/clusterTruster")
```

Examples
--------

### iris

We can analyze the iris data set as follows. We first center and scale the four features, "Sepal.Length", "Sepal.Width", "Petal.Length", "Petal.Width", and generate the l2 distance between all pairs. We then use single linkage, and generate all associated evaluation metrics.

``` r
allPairwise <- genPairwise(iris, 5)
iris[, 1:4] <- scale(iris[, 1:4])
allPairwise <- genSimDiff(iris, 1:4, allPairwise, 1:2, "l2dist")

outMetrics <- getMetrics(allPairwise, pairColNums = 1:2, matchColNum = 3, distSimCol = "l2dist", linkage = "single")
```

The package also contains an example data set, called `removedDups`. This analyzes 144 images of cartridge cases, taken from NIST's [Ballistics Toolmarks Research Database](https://tsapps.nist.gov/NRBTD). There are 12 images each taken from 12 different guns. Pairwise comparisons have been pre-computed using the [`cartridges3D` package](https://github.com/xhtai/cartridges3D), and stored in `removedDups`. In this case, we do not need to use the functions `genPairwise()` or `genSimDiff()`, and can simply input the appropriate data and column information into `getMetrics`, as follows.

``` r
NBIDEminimax <- getMetrics(removedDups, pairColNums = 1:2, matchColNum = "match", distSimCol = "corrMax", linkage = "minimax", dist = FALSE) 
```

This is some example code for generating plots, assuming that metrics have been generated using each linkage method and stored in a data frame with their corresponding names.

``` r
plot(single$numClusters, single$maxMinimax, xlab = "Number of clusters", ylab = "Max minimax radius", main = "Max minimax radius", type = "l")
lines(complete$numClusters, complete$maxMinimax, col = 2)
lines(average$numClusters, average$maxMinimax, col = 3)
lines(centroid$numClusters, centroid$maxMinimax, col = 4)
lines(minimax$numClusters, minimax$maxMinimax, col = 5)
legend("topright", legend = c("Single", "Complete", "Average", "Centroid", "Minimax"), col = 1:5, lty = c(1, 1, 1, 1, 1))
```

License
-------

The `clusterTruster` package is licensed under GPLv3 (<http://www.gnu.org/licenses/gpl.html>).
