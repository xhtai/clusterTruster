#' Generate pairwise comparisons
#'
#' @param datasetName name of data that is loaded in R e.g. AlonDS
#' @param labelColNum column number with cluster label
#'
#' @return data frame with all choose(n, 2) comparisons. Three columns: `hash1`
#'   is the row number in the original data set of the first item in the
#'   comparison, `hash2` is the second, and `match` is the ground truth for
#'   whether the pair is in the same cluster.
#' @export

genPairwise <- function(datasetName, labelColNum) {
    allPairwise <- t(combn(1:nrow(datasetName), 2))
    allPairwise <- data.frame(hash1 = allPairwise[, 1], hash2 = allPairwise[, 2], stringsAsFactors = FALSE)

    label1 <- datasetName[allPairwise$hash1, labelColNum]
    label2 <- datasetName[allPairwise$hash2, labelColNum]

    allPairwise$match <- ifelse(label1 == label2, 1, 0)
    return(allPairwise)
}


#' Generate either correlation, l1 or l2 distance, from feature(s)
#'
#' @param datasetName name of data containing individual information
#' @param featureCols column(s) containing features that correlation, l1 or l2
#'   distance are to be computed for
#' @param allPairwise name of data frame containing all pairwise comparisons.
#'   This needs to have at least two columns, one representing the first item in
#'   the comparison, and one representing the second item.
#' @param pairColNums vector of length 2 indicating the column numbers of 1.
#'   item 1 in comparison, 2. item 2 in comparison
#' @param measure either "correlation", "l2dist" or "l1dist"
#'
#' @return allPairwise with an additional column, either "correlation", "l2dist"
#'   or "l1dist"
#' @export

genSimDiff <- function(datasetName, featureCols, allPairwise, pairColNums, measure) {
  info1 <- datasetName[allPairwise[, pairColNums[1]], featureCols]
  info2 <- datasetName[allPairwise[, pairColNums[2]], featureCols]
  if (measure == "correlation") {
    corrs <- apply(cbind(info1, info2), MARGIN = 1, FUN = function(x) cor(as.numeric(x[1:ncol(info1)]), as.numeric(x[(ncol(info1) + 1):(2*ncol(info1))])))
    allPairwise$correlation <- corrs
  } else if (measure == "l2dist") {
    tmpDist <- sqrt(rowSums((info1 - info2)^2))
    allPairwise$l2dist <- tmpDist
  } else if (measure == "l1dist") {
    tmpDist <- rowSums(abs(info1 - info2))
    allPairwise$l1dist <- tmpDist
  }
  return(allPairwise)
}


#' Generate four evaluation metrics from pairwise comparisons
#'
#' This function runs hierarchical linkage using one of five linkage methods:
#' single linkage, complete linkage, average linkage, centroid linkage and
#' minimax linkage. For a data set with $n$ items, it is possible to get
#' clusterings of sizes 1 through n. For each cluster size, we compute four
#' evaluation metrics: 1. maximum minimax radius (see Bien et al. 2011), 2.
#' misclassification rate, 3. precision, 4. recall.
#'
#' @param allPairwise name of data frame containing all pairwise comparisons.
#'   This needs to have at least four columns, one representing the first item
#'   in the comparison, one representing the second item, one representing the
#'   true match/non-match status, and the last representing a distance or
#'   similarity metric. These are enumerated in the next three parameters.
#' @param pairColNums vector of length 2 indicating the column numbers in
#'   `allPairwise` of 1. item 1 in comparison, 2. item 2 in comparison
#' @param matchColNum column number of column in `allPairwise` indicating true
#'   match/non-match status
#' @param distSimCol name of column in `allPairwise` indicating distances or
#'   similarities, input as character, e.g. "l2dist". If this is a similarity
#'   and not a difference, input `myDist` parameter to be FALSE. If a similarity
#'   measure is used, distance will be calcualted as 1 - similarity.
#' @param linkage one of "single", "complete", "average", "centroid", "minimax"
#' @param myDist is `distSimCol` a distance or similarity measure? Default TRUE,
#'   i.e. distance measure
#'
#' @return outMetrics, a data frame with each row representing a clustering. For
#'   a data set with $n$ items, there will be $n$ rows. Columns are the four
#'   evaluation metrics, `maxMinimax`, `misClass`, `precision` and `recall`.
#' @export

getMetrics <- function(allPairwise, pairColNums, matchColNum, distSimCol, linkage, myDist = TRUE) {

      #### clustering
      testThis <- getHcluster(allPairwise, pairColNums, distSimCol, linkage, myDist)
      n <- length(unique(c(allPairwise[, pairColNums[1]], allPairwise[, pairColNums[2]])))

      for (i in 1:n) {
          allPairwise[sprintf("l%03d", i)] <- makeLinkCol(allPairwise, pairColNums, testThis, i, linkage)
      }

      #### evaluation
      outMetrics <- data.frame(numClusters = 1:n, maxMinimax = NA, misClass = NA, precision = NA, recall = NA)

      for (i in 1:nrow(outMetrics)) {
          if (i %% 10 == 0) cat(i, ", ")
          out <- distToPrototype(allPairwise, distSimCol, sprintf("l%03d", i), pairColNums, myDist)
          outMetrics$maxMinimax[i] <- max(out$minimaxRadius)
          outMetrics$misClass[i] <- misclassRate(allPairwise, sprintf("l%03d", i), matchColNum)
          out <- precisionRecall(allPairwise, sprintf("l%03d", i), matchColNum)

          outMetrics$precision[i] <- out$precision
          outMetrics$recall[i] <- out$recall
      }
    return(outMetrics)
}

