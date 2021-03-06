% Generated by roxygen2: do not edit by hand
% Please edit documentation in R/runMDS2.R
\name{runMDS2}
\alias{runMDS2}
\alias{calculateMDS2}
\alias{calculateMDS2,ANY-method}
\alias{calculateMDS2,SummarizedExperiment-method}
\alias{calculateMDS2,SingleCellExperiment-method}
\title{Perform MDS on sample-level data}
\usage{
calculateMDS2(x, ...)

\S4method{calculateMDS2}{ANY}(
  x,
  FUN = calculateDistance,
  ncomponents = 2,
  ntop = 500,
  subset_row = NULL,
  scale = FALSE,
  transposed = FALSE,
  keep_dist = FALSE,
  ...
)

\S4method{calculateMDS2}{SummarizedExperiment}(x, ..., exprs_values = "counts", FUN = calculateDistance)

\S4method{calculateMDS2}{SingleCellExperiment}(
  x,
  ...,
  exprs_values = "counts",
  dimred = NULL,
  n_dimred = NULL,
  FUN = calculateDistance
)

runMDS2(x, ..., altexp = NULL, name = "MDS2")
}
\arguments{
\item{x}{a \linkS4class{SingleCellExperiment} containing a numeric matrix of
expression values where rows are features and columns are cells.}

\item{...}{additional arguments to pass to \code{FUN}.}

\item{FUN}{a \code{function} or \code{character} value with a function name
returning a \code{\link[stats:dist]{dist}} object}

\item{ncomponents}{Numeric scalar indicating the number of MDS dimensions
to obtain.}

\item{ntop}{Numeric scalar specifying the number of features with the highest
variances to use for dimensionality reduction.}

\item{subset_row}{Vector specifying the subset of features to use for
dimensionality reduction. This can be a character vector of row names, an
integer vector of row indices or a logical vector.}

\item{scale}{Logical scalar, should the expression values be standardized?}

\item{transposed}{Logical scalar, is x transposed with cells in rows?}

\item{keep_dist}{\code{TRUE} or \code{FALSE}: Should the dist object be
returned as attribute of the MDS result? (default: code{keep_dist = FALSE})}

\item{exprs_values}{a single \code{character} value for specifying which
assay to use for calculation.}

\item{dimred}{String or integer scalar specifying the existing dimensionality
reduction results to use.}

\item{n_dimred}{Integer scalar or vector specifying the dimensions to use if
dimred is specified.}

\item{altexp}{String or integer scalar specifying an alternative experiment
containing the input data.}

\item{name}{String specifying the name to be used to store the result in the
reducedDims of the output.}
}
\value{
For \code{calculateMDS}, a matrix is returned containing the MDS
coordinates for each cell (row) and dimension (column).
}
\description{
Perform multi-dimensional scaling (MDS) on samples, based on the data in a
SingleCellExperiment object.
}
\details{
The function \code{\link{cmdscale}} is used internally to compute
the MDS components.
}
\examples{
# generate some example data
mat <- matrix(1:60, nrow = 6)
df <- DataFrame(n = c(1:6))
se <- SummarizedExperiment(assays = list(counts = mat),
                           rowData = df)
#
calculateMDS2(se)

#
data(esophagus)
esophagus <- runMDS2(esophagus, FUN = calculateUniFrac, name = "UniFrac",
                     tree = rowTree(esophagus))
reducedDim(esophagus)
}
\seealso{
\code{\link{cmdscale}}, to perform the underlying calculations.

\code{\link[scater:plotReducedDim]{plotMDS}}, to quickly visualize the
results.
}
\author{
Aaron Lun, based on code by Davis McCarthy, modified for flexible
distance function input by Felix G.M. Ernst
}
