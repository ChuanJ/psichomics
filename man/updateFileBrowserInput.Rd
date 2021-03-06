% Generated by roxygen2: do not edit by hand
% Please edit documentation in R/utils.R
\name{updateFileBrowserInput}
\alias{updateFileBrowserInput}
\title{Change the value of a fileBrowserInput on the client}
\source{
Original code by wleepang:
\url{https://github.com/wleepang/shiny-directory-input}
}
\usage{
updateFileBrowserInput(session, id, ..., value = NULL)
}
\arguments{
\item{session}{Shiny session}

\item{id}{Character: input identifier}

\item{...}{Additional arguments passed to \code{\link{fileBrowser}}. Only
used if \code{value} is \code{NULL}.}

\item{value}{Character: file or directory path}
}
\value{
NULL (this function is used to modify the Shiny session's state)
}
\description{
Change the value of a fileBrowserInput on the client
}
\details{
Sends a message to the client, telling it to change the value of the input
object. For \code{fileBrowserInput} objects, this changes the value displayed
in the text-field and triggers a client-side change event. A directory
selection dialogue is not displayed.
}
