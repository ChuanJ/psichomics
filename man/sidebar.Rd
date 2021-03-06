% Generated by roxygen2: do not edit by hand
% Please edit documentation in R/utils.R
\name{sidebar}
\alias{sidebar}
\title{Sidebar without a well}
\usage{
sidebar(..., width = 4)
}
\arguments{
\item{...}{UI elements to include on the sidebar}

\item{width}{The width of the sidebar. For fluid layouts this is out of 12
total units; for fixed layouts it is out of whatever the width of the
sidebar's parent column is.}
}
\value{
A sidebar that can be passed to \code{\link{sidebarLayout}}
}
\description{
Modified version of \code{shiny::sidebarPanel} without a well
}
\examples{
# Sidebar with controls to select a dataset and specify
# the number of observations to view
sidebarPanel(
  selectInput("dataset", "Choose a dataset:",
              choices = c("rock", "pressure", "cars")),

  numericInput("obs", "Observations:", 10)
)
}
