% Generated by roxygen2: do not edit by hand
% Please edit documentation in R/events.R
\name{sortCoordinates}
\alias{sortCoordinates}
\title{Sort coordinates for some event types}
\usage{
sortCoordinates(events)
}
\arguments{
\item{events}{List of data frames with alternative splicing events for a 
given program}
}
\value{
List of data frames with alternative splicing events for a given
program
}
\description{
Some programs sort the coordinates of specific event types differently. To
make them all comparable across programs, the coordinates are ordered by
increasing (plus strand) or decreasing order (minus strand)
}
