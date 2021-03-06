% Generated by roxygen2: do not edit by hand
% Please edit documentation in R/analysis.R
\name{plotDistribution}
\alias{plotDistribution}
\alias{plotDensity}
\title{Plot distribution through a density plot}
\usage{
plotDistribution(data, groups = "All samples", rug = TRUE,
  vLine = TRUE, ..., title = NULL, psi = NULL)

plotDensity(data, groups = "All samples", rug = TRUE, vLine = TRUE,
  ..., title = NULL, psi = NULL)
}
\arguments{
\item{data}{Numeric, data frame or matrix: data for one gene or alternative 
splicing event}

\item{groups}{List of characters (list of groups containing data identifiers)
or character vector (group of each value in \code{data})}

\item{rug}{Boolean: include rug plot to better visualise data distribution}

\item{vLine}{Boolean: include vertical plot lines to display descriptive 
statistics for each group}

\item{...}{Extra parameters passed to \code{density} to create the kernel
density estimates}

\item{title}{Character: plot title}

\item{psi}{Boolean: are data composed of PSI values? Automatically set to
\code{TRUE} if all \code{data} values are between 0 and 1}
}
\value{
Highcharter object with density plot
}
\description{
The tooltip shows the median, variance, max, min and number of non-NA samples
of each data series.
}
\examples{
data <- sample(20, rep=TRUE)/20
groups <- c(rep("A", 10), rep("B", 10))
plotDistribution(data, groups)
}
