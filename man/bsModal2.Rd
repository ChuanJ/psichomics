% Generated by roxygen2: do not edit by hand
% Please edit documentation in R/utils.R
\name{bsModal2}
\alias{bsModal2}
\title{Modified version of \code{shinyBS::bsModal}}
\usage{
bsModal2(id, title, trigger, ..., size = NULL, footer = NULL,
  style = NULL)
}
\arguments{
\item{id}{A unique identifier for the modal window}

\item{title}{The title to appear at the top of the modal}

\item{trigger}{The id of a button or link that will open the modal.}

\item{...}{UI elements to include within the modal}

\item{size}{Character: Modal size (\code{small}, \code{default} or 
\code{large})}

\item{footer}{UI set: List of elements to include in the footer}

\item{style}{Character: message style can be \code{warning}, \code{error}, 
\code{info} or \code{NULL}}
}
\value{
HTML elements
}
\description{
\code{bsModal} is used within the UI to create a modal window. This allows to
modify the modal footer.
}
