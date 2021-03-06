#' Calculation of Double Principal Correspondance analysis
#'
#' Double Principal Correspondance analysis is made available via the
#' \code{ade4} package in typical fashion. Results are stored in the
#' \code{reducedDims} and are available for all the expected functions.
#'
#' @param x For \code{calculateDPCoA}, a numeric matrix of expression values
#'   where rows are features and columns are cells.
#'   Alternatively, a \code{TreeSummarizedExperiment} containing such a matrix.
#'
#'   For \code{runDPCoA} a \linkS4class{TreeSummarizedExperiment} containing the
#'   expression values as well as a \code{rowTree} to calculate \code{y} using
#'   \code{\link[ape:cophenetic.phylo]{cophenetic.phylo}}.
#'
#' @param y a \code{dist} or a symmetric \code{matrix} comaptible with
#'   \code{ade4:dpcoa}
#'
#' @param ncomponents Numeric scalar indicating the number of DPCoA dimensions
#'   to obtain.
#'
#' @param ntop Numeric scalar specifying the number of features with the highest
#'   variances to use for dimensionality reduction. Alternatively \code{NULL},
#'   if all feature should be used. (default: \code{ntop = NULL})
#'
#' @param subset_row Vector specifying the subset of features to use for
#'   dimensionality reduction. This can be a character vector of row names, an
#'   integer vector of row indices or a logical vector.
#'
#' @param scale Logical scalar, should the expression values be standardized?
#'
#' @param transposed Logical scalar, is x transposed with cells in rows?
#'
#' @param exprs_values a single \code{character} value for specifying which
#'   assay to use for calculation.
#'
#' @param dimred String or integer scalar specifying the existing dimensionality
#'   reduction results to use.
#'
#' @param n_dimred Integer scalar or vector specifying the dimensions to use if
#'   dimred is specified.
#'
#' @param altexp String or integer scalar specifying an alternative experiment
#'   containing the input data.
#'
#' @param name String specifying the name to be used to store the result in the
#'   reducedDims of the output.
#'
#' @param ... Currently not used.
#'
#' @details
#' In addition to the recuced dimension on the features, the reduced dimension
#' for samples are returned as well as \code{sample_red} attribute.
#' \code{eig}, \code{feature_weights} and \code{sample_weights} are
#' returned as attributes as well.
#'
#' @name runDPCoA
#' @seealso
#' \code{\link[scater:plotReducedDim]{plotReducedDim}}
#' \code{\link[SingleCellExperiment:reducedDims]{reducedDims}}
#'
#' @examples
#' data(esophagus)
#' dpcoa <- calculateDPCoA(esophagus)
#' head(dpcoa)
#'
#' esophagus <- runDPCoA(esophagus)
#' reducedDims(esophagus)
#'
#' library(scater)
#' plotReducedDim(esophagus, "DPCoA")
NULL

#' @export
#' @rdname runDPCoA
setGeneric("calculateDPCoA", signature = c("x", "y"),
           function(x, y, ...)
               standardGeneric("calculateDPCoA"))

.calculate_dpcoa <- function(x, y, ncomponents = 2, ntop = NULL,
                             subset_row = NULL, scale = FALSE,
                             transposed = FALSE)
{
    .require_package("ade4")
    # input check
    y <- as.matrix(y)
    if(length(unique(dim(y))) != 1L){
        stop("'y' must be symmetric.", call. = FALSE)
    }
    #
    if(!transposed) {
        if(is.null(ntop)){
            ntop <- nrow(x)
        }
        x <- .get_mat_for_reddim(x, subset_row = subset_row, ntop = ntop,
                                 scale = scale)
    }
    y <- y[colnames(x),colnames(x)]
    if(nrow(y) != ncol(x)){
        stop("x and y must have corresponding dimensions.", call. = FALSE)
    }
    y <- sqrt(y)
    y <- as.dist(y)
    #
    dpcoa <- ade4::dpcoa(data.frame(x), y, scannf = FALSE, nf = ncomponents)
    ans <- as.matrix(dpcoa$li)
    rownames(ans) <- rownames(x)
    colnames(ans) <- NULL
    attr(ans,"eig") <- dpcoa$eig
    tmp <- as.matrix(dpcoa$dls)
    rownames(tmp) <- colnames(x)
    colnames(tmp) <- NULL
    attr(ans,"sample_red") <- tmp
    attr(ans,"feature_weights") <- unname(dpcoa$dw)
    attr(ans,"sample_weights") <- unname(dpcoa$lw)
    ans
}

#' @export
#' @rdname runDPCoA
setMethod("calculateDPCoA", c("ANY","ANY"), .calculate_dpcoa)

#' @export
#' @importFrom ape cophenetic.phylo
#' @rdname runDPCoA
setMethod("calculateDPCoA", signature = c("TreeSummarizedExperiment","missing"),
    function(x, ..., exprs_values = "counts", dimred = NULL, n_dimred = NULL)
    {
        .require_package("ade4")
        mat <- assay(x, exprs_values)
        dist <- cophenetic.phylo(rowTree(x))
        calculateDPCoA(mat, dist, ...)
    }
)

#' @export
#' @rdname runDPCoA
#' @importFrom SingleCellExperiment reducedDim<-
runDPCoA <- function(x, ..., altexp = NULL, name = "DPCoA"){
    if (!is.null(altexp)) {
        y <- altExp(x, altexp)
    } else {
        y <- x
    }
    reducedDim(x, name) <- calculateDPCoA(y, ...)
    x
}
