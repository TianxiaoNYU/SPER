% Generated by roxygen2: do not edit by hand
% Please edit documentation in R/SPER.R
\name{weightSPER}
\alias{weightSPER}
\title{Weight SPER list to one score matrix}
\usage{
weightSPER(reshape.pair.list, weight)
}
\arguments{
\item{reshape.pair.list}{SPER list of subscore matrices}

\item{weight}{A weight to apply. Must have the same length as the distance list.}
}
\value{
A matrix containing the SPER scores of all pairs
}
\description{
Apply a weight to the SPER list and integrate the subscores at different distance into one matrix
}
