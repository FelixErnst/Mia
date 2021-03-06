#' Loading a biom file
#'
#' For convenciance a few functions are available to convert data from a
#' \sQuote{biom} file or object into a
#' \code{\link[TreeSummarizedExperiment:TreeSummarizedExperiment-class]{TreeSummarizedExperiment}}
#'
#' @param file biom file location
#'
#' @return An object of class
#'   \code{\link[TreeSummarizedExperiment:TreeSummarizedExperiment-class]{TreeSummarizedExperiment}}
#'
#' @name makeTreeSummarizedExperimentFromBiom
#' @seealso
#' \code{\link[=makeTreeSummarizedExperimentFromDADA2]{makeTreeSummarizedExperimentFromDADA2}}
#' \code{\link[=makeTreeSummarizedExperimentFromphyloseq]{makeTreeSummarizedExperimentFromphyloseq}}
#' \code{\link[=loadFromQIIME2]{loadFromQIIME2}}
#'
#' @examples
#' if(requireNamespace("biomformat")) {
#'   library(biomformat)
#'   # load from file
#'   rich_dense_file  = system.file("extdata", "rich_dense_otu_table.biom",
#'                                  package = "biomformat")
#'   tse <- loadFromBiom(rich_dense_file)
#'
#'   # load from object
#'   x1 <- biomformat::read_biom(rich_dense_file)
#'   tse <- makeTreeSummarizedExperimentFromBiom(x1)
#'   tse
#' }
NULL

#' @rdname makeTreeSummarizedExperimentFromBiom
#'
#' @export
loadFromBiom <- function(file) {
    .require_package("biomformat")
    biom <- biomformat::read_biom(file)
    makeTreeSummarizedExperimentFromBiom(biom)
}

#' @rdname makeTreeSummarizedExperimentFromBiom
#'
#' @param obj object of type \code{\link[biomformat:read_biom]{biom}}
#'
#' @export
makeTreeSummarizedExperimentFromBiom <- function(obj){
    # input check
    .require_package("biomformat")
    if(!is(obj,"biom")){
        stop("'obj' must be a 'biom' object")
    }
    #
    counts <- as(biomformat::biom_data(obj), "matrix")
    sample_data <- biomformat::sample_metadata(obj)
    feature_data <- biomformat::observation_metadata(obj)

    TreeSummarizedExperiment(assays = list(counts = counts),
                             colData = sample_data,
                             rowData = feature_data)
}
