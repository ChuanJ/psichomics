% Generated by roxygen2: do not edit by hand
% Please edit documentation in R/utils.R
\name{styleModal}
\alias{styleModal}
\alias{errorModal}
\alias{warningModal}
\alias{infoModal}
\title{Style and show a modal}
\usage{
styleModal(session, title, ..., style = NULL,
  iconName = "exclamation-circle", footer = NULL, echo = FALSE,
  size = "medium", dismissButton = TRUE, caller = NULL)

errorModal(session, title, ..., size = "small", footer = NULL,
  caller = NULL)

warningModal(session, title, ..., size = "small", footer = NULL,
  caller = NULL)

infoModal(session, title, ..., size = "small", footer = NULL,
  caller = NULL)
}
\arguments{
\item{session}{Current Shiny session}

\item{title}{Character: modal title}

\item{...}{Extra arguments to pass to \code{shiny::modalDialog}}

\item{style}{Character: style of the modal (NULL, "warning", "error" or 
"info"; NULL by default)}

\item{iconName}{Character: FontAwesome icon name to appear with the title}

\item{footer}{HTML elements to use in footer}

\item{echo}{Boolean: print to console? FALSE by default}

\item{size}{Character: size of the modal - "medium" (default), "small" or 
"large"}

\item{dismissButton}{Boolean: show dismiss button in footer? TRUE by default}

\item{caller}{Character: label to identify the module calling for the modal 
(relevant for error and warning modals)}
}
\value{
NULL (this function is used to modify the Shiny session's state)
}
\description{
You can also use \code{errorModal} and \code{warningModal} to use a template 
modal already stylised to show errors and warnings, respectively.
}
\seealso{
\code{\link{showAlert}}
}
