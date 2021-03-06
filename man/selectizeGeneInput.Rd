% Generated by roxygen2: do not edit by hand
% Please edit documentation in R/analysis.R
\name{selectizeGeneInput}
\alias{selectizeGeneInput}
\title{Create input to select a gene}
\usage{
selectizeGeneInput(id, label = "Gene", choices = NULL,
  multiple = FALSE)
}
\arguments{
\item{id}{Character: identifier}

\item{label}{Display label for the control, or \code{NULL} for no label.}

\item{choices}{List of values to select from. If elements of the list are
named, then that name rather than the value is displayed to the user.
This can also be a named list whose elements are (either named or
unnamed) lists or vectors. If this is the case, the outermost names
will be used as the "optgroup" label for the elements in the respective
sublist. This allows you to group and label similar choices. See the
example section for a small demo of this feature.}

\item{multiple}{Is selection of multiple items allowed?}
}
\value{
HTML elements
}
\description{
Create input to select a gene
}
