#' Transform Counts
#'
#' These functions provide a variety of options for transforming abundance data.
#' By using \code{transformCounts}, transformed table is in \code{assay}. By using
#' specific \code{ZTransform} function, Z-transformation can be applied for features.
#' \code{relAbundanceCounts} is a shortcut for fetching relative abundance table.
#'
#' @param x
#' A \code{\link[SummarizedExperiment:SummarizedExperiment-class]{SummarizedExperiment}}
#' object.
#'
#' @param abund_values
#' A single character value for selecting the
#'   \code{\link[SummarizedExperiment:SummarizedExperiment-class]{assay}}
#'   to be transformed.
#'
#' @param method
#' A single character value for selecting the transformation method.
#'
#' @param name
#' A single character value specifying the name of transformed abundance table.
#'
#' @param pseudocount
#' FALSE or numeric value deciding whether pseudocount is added. Numerical
#' value specifies the value of pseudocount.
#'
#' @param threshold
#' A numeric value for setting threshold for pa transformation. By default it is 0.
#'
#' @param ... additional arguments
#'
#' @details
#' \code{transformCounts} applies transformation to abundance table.
#' Provided transformation methods include:
#'
#' \itemize{
#' \item {'relabundance'}{ Transforms abundances to relative. Generally, all microbiome
#' data are compositional. That is, e.g., because all measuring instruments have their capacity limits.
#' To make results comparable with other results, values must be relative. (See e.g. Gloor et al. 2017.)
#'
#' \deqn{relabundance = \frac{x}{x_{tot}}}{%
#' relabundance = x/x_tot}
#' where \eqn{x} is a single value and \eqn{x_{tot}} is the sum of
#' all values.}
#'
#' \item{'log10'}{ log10 transformation can be used for reducing the skewness of the data.
#'
#' \deqn{log10 = \log_10 x}{%
#' log10 = log10(x)}
#' where \eqn{x} is a single value of data.}
#'
#' \item{'pa'}{ Transforms table to presence/absence table. All abundances higher
#' than \eqn{\epsilon} are transformed to 1 (present), otherwise 0 (absent). By default, threshold is 0.}
#'
#' \item{'Z'}{ Z-transformation, Z score transformation, or Z-standardization normalizes
#' the data by shifting (to mean \eqn{\mu}) and scaling (to standard deviation \eqn{\sigma}).
#' Z-transformation can be done with function \code{ZTransform}. It is done per rows.
#' In other words, single value is standardized with respect of feature's values.
#'
#' \deqn{Z = \frac{x + \mu}{\sigma}}{%
#' Z = (x + µ)/σ}
#' where \eqn{x} is a single value, \eqn{\mu} is the mean of the feature, and
#' \eqn{\sigma} is the standard deviation of the feature.}
#'
#' \item{'hellinger'}{ Hellinger transformation can be used to reduce the impact of
#' extreme data points. It can be utilize for clustering or ordination analysis.
#' (See e.g. Legendre & Gallagher 2001.)
#'
#' \deqn{hellinger = \sqrt{\frac{x}{x_{tot}}}}{%
#' hellinger = sqrt(x/x_tot)}
#' where \eqn{x} is a single value and \eqn{x_{tot}} is the sum of
#' all values}
#'
#' \item{'clr'}{ Centered log ratio (clr) transformation can be used for reducing the
#' skewness of data and for centering it. (See e.g. Gloor et al. 2017.)
#'
#' \deqn{clr = log_{10}x_{r} - log_{10}µ_{r}}{%
#' clr = log10 x_r - log10 µ_r}
#' where \eqn{x_{r}} is a single relative value, \eqn{\mu_{r}} is
#' mean relative value".}
#'
#' }
#'
#' @references
#' Gloor GB, Macklaim JM, Pawlowsky-Glahn V & Egozcue JJ (2017)
#' Microbiome Datasets Are Compositional: And This Is Not Optional.
#' Frontiers in Microbiology 8: 2224. doi: 10.3389/fmicb.2017.02224
#'
#' Legendre P & Gallagher ED (2001)
#' Ecologically meaningful transformations for ordination of species data.
#' Oecologia 129: 271-280.
#'
#'
#' @return
#' \code{transformCounts}, \code{relAbundanceCounts}, and \code{ZTransform} return
#' \code{x} with additional, transformed abundance table named \code{*name*} in
#' the \code{\link{assay}}.
#'
#' @name transformCounts
#' @export
#'
#' @author Leo Lahti and Tuomas Borman. Contact: \url{microbiome.github.io}
#'
#' @examples
#' data(esophagus)
#' x <- esophagus
#'
#' # By specifying, it is possible to apply different transformations, e.g. clr transformation.
#' # Pseudocount can be added by specifying 'pseudocount'.
#' x <- transformCounts(x, method="clr", pseudocount=1)
#' head(assay(x, "clr"))
#'
#' # Name of the stored table can be specified. Also, the target of transformation
#' # can be specified with "abund_values".
#' x <- transformCounts(x, method="hellinger", name="test", pseudocount=5)
#' head(assay(x, "test"))
#'
#' x <- transformCounts(x, method="relabundance", abund_values="test")
#' head(assay(x, "relabundance"))
#'
#' # pa returns presence absence table. With 'threshold', it is possible to set the
#' # threshold to desired level. By default, it is 0.
#' x <- transformCounts(x, method="pa", threshold=35)
#' head(assay(x, "pa"))
#'
#' # Z-transform can be done for features
#' x <- ZTransform(x, pseudocount=1)
#' head(assay(x, "ZTransform"))
#'
#' # Relative abundances can be also calculate with the dedicated
#' # relAbundanceCounts function.
#' x <- relAbundanceCounts(x)
#' head(assay(x, "relabundance"))
NULL

#' @rdname transformCounts
#' @export
setGeneric("transformCounts", signature = c("x"),
           function(x,
                    abund_values = "counts",
                    method = c("relabundance", "log10", "pa", "hellinger", "clr"),
                    name = method,
                    pseudocount = FALSE,
                    threshold = 0)
               standardGeneric("transformCounts"))


#' @rdname transformCounts
#' @export
setMethod("transformCounts", signature = c(x = "SummarizedExperiment"),
    function(x,
             abund_values = "counts",
             method = c("relabundance", "log10", "pa", "hellinger", "clr"),
             name = method,
             pseudocount = FALSE,
             threshold = 0){

        # Input check
        # Check abund_values
        .check_abund_values(abund_values, x)

        # Check method
        # If method is not single string, user has not specified transform method,
        # or has given e.g. a vector
        if(!.is_non_empty_string(method)){
            stop("'method' must be a non-empty single character value. \n",
                 "Give one method from the following list: \n",
                 "'relabundance', 'log10', 'pa', 'hellinger', 'clr'",
                 call. = FALSE)
        }
        method <- match.arg(method)

        # Check name
        if(!.is_non_empty_string(name) ||
           name == abund_values){
            stop("'name' must be a non-empty single character value and be ",
                 "different from `abund_values`.",
                 call. = FALSE)
        }

        # Check pseudocount
        if(!(pseudocount==FALSE || is.numeric(pseudocount))){
            stop("'pseudocount' must be FALSE or numeric value.",
                 call. = FALSE)
        }

        # Check threshold
        if(!is.numeric(threshold)){
            stop("'threshold' must be a numeric value, and it can be used ",
                 "only with transformation method 'pa'.",
                 call. = FALSE)
        }

        # Get transformed table
        transformed_table <-
            .get_transformed_table(assay = assay(x, abund_values),
                                   method = method,
                                   pseudocount = pseudocount,
                                   threshold = threshold)

        # Assign transformed table to assays
        assay(x, name, withDimnames=FALSE) <- transformed_table
        x
    }
)

##################################Z-TRANSFORM###################################

#' @rdname transformCounts
#' @export
setGeneric("ZTransform", signature = c("x"),
           function(x,
                    abund_values = "counts",
                    name = "ZTransform",
                    pseudocount = FALSE)
               standardGeneric("ZTransform"))


#' @rdname transformCounts
#' @export
setMethod("ZTransform", signature = c(x = "SummarizedExperiment"),
    function(x,
             abund_values = "counts",
             name = "ZTransform",
             pseudocount = FALSE){

        # Input check
        # Check abund_values
        .check_abund_values(abund_values, x)

        # Check name
        if(!.is_non_empty_string(name) ||
           name == abund_values){
            stop("'name' must be a non-empty single character value and be ",
                 "different from `abund_values`.",
                 call. = FALSE)
        }

        # Check pseudocount
        if(!(pseudocount==FALSE || is.numeric(pseudocount))){
          stop("'pseudocount' must be FALSE or numeric value.",
               call. = FALSE)
        }

        # Get transformed table
        transformed_table <- .calc_ztransform(mat = assay(x, abund_values),
                                            pseudocount = pseudocount)

        # Assign transformed table to assays
        assay(x, name) <- transformed_table
        x
    }
)

###############################relAbundanceCounts###############################

#' @rdname transformCounts
setGeneric("relAbundanceCounts", signature = c("x"),
           function(x, ...)
               standardGeneric("relAbundanceCounts"))

#' @rdname transformCounts
#' @importFrom SummarizedExperiment assay assay<-
#' @export
setMethod("relAbundanceCounts",signature = c(x = "SummarizedExperiment"),
    function(x, ...){
        transformCounts(x, method = "relabundance", ...)
    }
)

###########################HELP FUNCTIONS####################################


# Chooses which transformation function is applied
.get_transformed_table <- function(assay, method, pseudocount, threshold){

    assay <- .apply_pseudocount(assay, pseudocount)

    # Function is selected based on the "method" variable
    FUN <- switch(method,
                  relabundance = .calc_rel_abund,
                  log10 = .calc_log10,
                  pa = .calc_pa,
                  hellinger = .calc_hellinger,
                  clr = .calc_clr)

    # Does the function call, arguments are "assay" abundance table and "pseudocount"
    do.call(FUN,
            list(mat = assay,
                 threshold = threshold))
}

#' @importFrom DelayedMatrixStats colSums2
.calc_rel_abund <- function(mat, threshold){

    mat <- sweep(mat, 2, colSums2(mat, na.rm = TRUE), "/")

    return(mat)
}

.calc_log10 <- function(mat, threshold){

    # If abundance table contains zeros, gives an error, because it is not possible
    # to calculate log from zeros. If there is no zeros, calculates log.
    if (any(mat <= 0, na.rm = TRUE)) {
        stop("Abundance table contains zero or negative values and ",
             "log10 transformation is being applied without pseudocount. ",
             "Try log10 with pseudocount = 1 or other numeric value.",
             call. = FALSE)
    }

    mat <- log10(mat)

    return(mat)
}

.calc_pa <- function(mat, threshold){
    # If value is over zero, gets value 1. If value is zero, gets value 0.
    mat <- (mat > threshold) - 0L
    return(mat)
}

.calc_hellinger <- function(mat, threshold){

    # If there is negative values, gives an error.
    if (any(mat < 0, na.rm = TRUE)) {
        stop("Abundance table contains negative values and hellinger ",
             "transformation is being applied without pseudocount. Try ",
             "hellinger with pseudocount = 1 or other numeric value.",
             call. = FALSE)
    }

    # Gets the relative abundance
    mat <- .calc_rel_abund(mat)

    # Takes square root
    mat <- sqrt(mat)

    return(mat)
}

#' @importFrom DelayedMatrixStats colMeans2
.calc_clr <- function(mat, threshold){

    # If there is negative values, gives an error.
    if (any(mat <= 0, na.rm = TRUE)) {
        stop("Abundance table contains zero or negative values and ",
             "clr-transformation is being applied without pseudocount. ",
             "Try clr with pseudocount = 1 or other numeric value.",
             call. = FALSE)
    }

    mat <- .calc_rel_abund(mat)

    # In every sample, calculates the log of individual entries. After that calculates
    # the sample-specific mean value and subtracts every entries' value with that.
    clog <- log(mat)
    clogm <- colMeans2(clog)
    mat <- t(t(clog) - clogm)

    return(mat)
}

#' @importFrom DelayedMatrixStats rowMeans2 rowSds
.calc_ztransform <- function(mat, pseudocount){

    mat <- .apply_pseudocount(mat, pseudocount)

    # Log10 can not be calculated if there is zero
    if (any(mat <= 0, na.rm = TRUE)) {
        stop("Abundance table contains zero or negative values and ",
             "Z-transformation is being applied without pseudocount. ",
             "Try ZTransform with pseudocount = 1 or other numeric value.",
             call. = FALSE)
    }

    # Gets the log transformed table
    mat <- .calc_log10(mat)

    # Z transform for features
    # Centers the feature data. After that, divides with
    # the standard deviation of feature.
    rm <- rowMeans2(mat, na.rm = TRUE)
    rsd <- rowSds(mat, na.rm = TRUE)

    mat <- (mat - rm)/rsd

    return(mat)
}

.apply_pseudocount <- function(mat, pseudocount){
    # If "pseudocount" is not FALSE, it is numeric value specified by user. Then add pseudocount.
    if(!pseudocount==FALSE){
        mat <- mat + pseudocount
    }
    mat
}
