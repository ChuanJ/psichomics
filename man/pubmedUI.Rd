% Generated by roxygen2: do not edit by hand
% Please edit documentation in R/analysis_information.R
\name{pubmedUI}
\alias{pubmedUI}
\title{Return the interface of relevant PubMed articles for a given gene}
\usage{
pubmedUI(gene, ...)
}
\arguments{
\item{gene}{Character: gene}

\item{...}{Arguments passed on to \code{queryPubMed}
\describe{
  \item{top}{Numeric: number of articles to retrieve (3 by default)}
  \item{field}{Character: field of interest where to look for terms ("abstract"
by default)}
  \item{sort}{Character: sort by a given parameter ("relevance" by default)}
}}
}
\value{
HTML interface of relevant PubMed articles
}
\description{
Return the interface of relevant PubMed articles for a given gene
}
