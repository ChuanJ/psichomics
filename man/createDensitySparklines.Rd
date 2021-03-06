% Generated by roxygen2: do not edit by hand
% Please edit documentation in R/analysis.R
\name{createDensitySparklines}
\alias{createDensitySparklines}
\title{Create density sparklines for inclusion levels}
\usage{
createDensitySparklines(data, events, areSplicingEvents = TRUE,
  groups = NULL, geneExpr = NULL)
}
\arguments{
\item{data}{Character: HTML-formatted data series of interest}

\item{events}{Character: event identifiers}

\item{areSplicingEvents}{Boolean: are these splicing events (TRUE) or gene 
expression (FALSE)?}

\item{groups}{Character: name of the groups used for differential analyses}

\item{geneExpr}{Character: name of the gene expression dataset}
}
\value{
HTML element with sparkline data
}
\description{
Create density sparklines for inclusion levels
}
