% Generated by roxygen2: do not edit by hand
% Please edit documentation in R/groups.R
\name{groupsServerOnce}
\alias{groupsServerOnce}
\title{Server function for data grouping (one call)}
\usage{
groupsServerOnce(input, output, session)
}
\arguments{
\item{input}{Input object}

\item{output}{Output object}

\item{session}{Session object}
}
\value{
NULL (this function is used to modify the Shiny session's state)
}
\description{
These functions only run once instead of running for every instance of groups
}
