#' Get dominant taxa
#'
#' These functions return information about the most dominant taxa in a
#' \code{\link{SummarizedExperiment-class}} object. Additionally, the
#' information can be directly stored in the \code{colData}.
#'
#' @param x A
#'   \code{\link[SummarizedExperiment:SummarizedExperiment-class]{SummarizedExperiment}}
#'   object.
#'
#' @param abund_values A single character value for selecting the
#'   \code{\link[SummarizedExperiment:SummarizedExperiment-class]{assay}}
#'   to use for prevalence calculation.
#'
#' @param rank A single character defining a taxonomic rank. Must be a value of
#'   the output of \code{taxonomicRanks()}.
#'
#' @param group With group, it is possible to group the observations in an
#'   overview. Must be a one of the column names of \code{colData}.
#'
#' @param name A name for the column of the \code{colData} where the dominant
#'   taxa will be stored in.
#'
#' @details
#' \code{dominantTaxa} extracts the most abundant taxa in a
#' \code{\link[=SummarizedExperiment-class]{SummarizedExperiment}} object, and
#' stores the information in the \code{colData}. \code{GetDominantTaxa} returns
#' information about most dominant taxa in a tibble. Information includes their
#' absolute and relative abundances in whole data set.
#'
#' With 'rank' parameter, it is possible to agglomerate taxa based on taxonomic
#' ranks. E.g. if 'family' rank is used, all abundances of same family is added
#' together, and those families are returned.
#'
#' With 'group' parameter, it is possible to group observations of returned
#' overview based on samples' features.  E.g., if samples contain information
#' about patients' health status, it is possible to group observations, e.g. to
#' 'healthy' and 'sick', and get the most dominant taxa of different health
#' status.
#'
#' @return \code{dominantTaxa} returns \code{x} with additional
#'   \code{\link{colData}} named \code{*name*}. \code{getDominantTaxa} returns
#'   an overview in a tibble. It contains dominant taxa in a column named
#'   \code{*name*} and its abundance in the data set.
#'
#' @name dominantTaxa
#' @export
#'
#' @author Leo Lahti and Tuomas Borman. Contact: \url{microbiome.github.io}
#'
#' @examples
#' data(GlobalPatterns)
#' x <- GlobalPatterns
#'
#' # Finds the dominant taxa.
#' x <- dominantTaxa(x)
#' # Information is stored to colData
#' colData(x)
#' # Gets the overview of dominant taxa
#' overview <- getDominantTaxa(x)
#' overview
#'
#' # If taxonomic information is available, it is possible to find the most
#' # dominant group from specific taxonomic level, here family level. The name
#' # of column can be specified.
#' x <- dominantTaxa(x, rank="Family", name="dominant_taxa_ranked_with_family")
#' colData(x)
#' # Gets the overview of dominant taxa
#' overview <- getDominantTaxa(x)
#' overview
#'
#' x <- microbiomeDataSets::dietswap()
#' x <- dominantTaxa(x)
#' colData(x)
#' # With group, it is possible to group observations based on groups specified
#' # Gets the overview of dominant taxa
#' overview <- getDominantTaxa(x, group = "nationality")
#' overview
NULL

#' @rdname dominantTaxa
#' @export
setGeneric("dominantTaxa",signature = c("x"),
           function(x,
                    abund_values = "counts",
                    rank = NULL,
                    name = "dominant_taxa")
               standardGeneric("dominantTaxa"))


#' @rdname dominantTaxa
#' @importFrom utils tail
#' @importFrom IRanges IntegerList relist
#' @export
setMethod("dominantTaxa", signature = c(x = "SummarizedExperiment"),
    function(x,
             abund_values = "counts",
             rank = NULL,
             name = "dominant_taxa"){

        # Input check
        # Check abund_values
        .check_abund_values(abund_values, x)

        # rank check
        if(!is.null(rank)){
            if(!.is_a_string(rank)){
                stop("'rank' must be an single character value.",
                     call. = FALSE)
            }
            .check_taxonomic_rank(rank, x)
        }

        # name check
        if(!.is_non_empty_string(name)){
            stop("'name' must be a non-empty single character value.",
                 call. = FALSE)
        }

        # If "rank" is not NULL, species are aggregated according to the
        # taxonomic rank that is specified by user.
        if (!is.null(rank)) {
            # Selects the level
            col <- which( taxonomyRanks(x) %in% rank )

            # Function from taxonomy.R. Divides taxas to groups where they
            # belong.
            tax_factors <- .get_tax_groups(x, col = col, onRankOnly = FALSE)

            # Merges abundances within the groups
            tmp <- mergeRows(x, f = tax_factors)

            # Stores abundances
            mat <- assay(tmp, abund_values)

            # Changes the name of species to the name of corresponding rank
            # If name contains upper rank, it is cut off
            # Tax_factors[rownames(mat)] finds corresponding name
            rownames(mat) <- tax_factors[rownames(mat)]

            # Splits the rownames from "_" and takes the last single string
            # --> upper ranks are removed
            rownames(mat) <- vapply(strsplit(rownames(mat), "_"),
                                    tail,
                                    character(1),
                                    n = 1)
        } # Otherwise, if "rank" is NULL, abundances are stored without ranking
        else {
            mat <- assay(x, abund_values)
        }

        # apply() function finds the indices of taxa's that has the highest
        # abundance.
        # rownames() returns the names of taxa that are the most abundant.
        idx <- IntegerList(as.list(apply(t(mat) == colMaxs(mat),1L,which)))
        taxas <- rownames(mat)[unlist(idx)]
        # relist, if ties exists and more than one row is equal to the
        # maximum
        if(length(unique(lengths(idx))) != 1L){
            taxas <- relist(taxas,idx)
        }

        # Adds taxa to colData
        x <- .add_dominant_taxas_to_colData(x, taxas, name)
        x
    }
)

#' @rdname dominantTaxa
#' @export
setGeneric("getDominantTaxa",signature = c("x"),
           function(x,
                    abund_values = "counts",
                    rank = NULL,
                    group = NULL,
                    name = "dominant_taxa")
               standardGeneric("getDominantTaxa"))


#' @rdname dominantTaxa
#' @export
setMethod("getDominantTaxa", signature = c(x = "SummarizedExperiment"),
    function(x,
             abund_values = "counts",
             rank = NULL,
             group = NULL,
             name = "dominant_taxa"){

        # Input check
        # group check
        if(!is.null(group)){
        if(isFALSE(any(group %in% colnames(colData(x))))){
          stop("'group' variable must be in colnames(colData(x))")
        }
        }

        # Adds dominant taxas to colData
        tmp <- dominantTaxa(x, abund_values, rank, name)

        # Gets an overview
        overview <- .get_overview(tmp, group, name)
        overview
    }
)

################################HELP FUNCTIONS##################################
#' @importFrom SummarizedExperiment colData colData<-
#' @importFrom S4Vectors DataFrame
.add_dominant_taxas_to_colData <- function(x, dominances, name){
    dominances <- DataFrame(dominances)
    colnames(dominances) <- name
    colData(x)[,name] <- dominances
    x
}

#' @importFrom S4Vectors as.data.frame
#' @importFrom dplyr n desc tally group_by arrange mutate
.get_overview <- function(x, group, name){

    # Creates a tibble df that contains dominant taxa and number of times that
    # they present in samples and relative portion of samples where they
    # present.
    if (is.null(group)) {
        name <- sym(name)

        overview <- as.data.frame(colData(x)) %>%
            group_by(!!name) %>%
            tally() %>%
            mutate(
                rel.freq = round(100 * n / sum(n), 1),
                rel.freq.pct = paste0(round(100 * n / sum(n), 0), "%")
            ) %>%
            arrange(desc(n))
    } else {
        group <- sym(group)
        name <- sym(name)

        overview <- as.data.frame(colData(x)) %>%
            group_by(!!group, !!name) %>%
            tally() %>%
            mutate(
                rel.freq = round(100 * n / sum(n), 1),
                rel.freq.pct = paste0(round(100 * n / sum(n), 0), "%")
            ) %>%
            arrange(desc(n))
    }

    return(overview)
}

