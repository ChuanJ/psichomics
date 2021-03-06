% Generated by roxygen2: do not edit by hand
% Please edit documentation in R/analysis.R
\name{testSurvivalCutoff}
\alias{testSurvivalCutoff}
\title{Test the survival difference between two survival groups given a cutoff}
\usage{
testSurvivalCutoff(cutoff, data, filter = TRUE, clinical, ...,
  session = NULL, survivalInfo = FALSE)
}
\arguments{
\item{cutoff}{Numeric: Cutoff of interest}

\item{data}{Numeric: elements of interest to test against the cutoff}

\item{filter}{Boolean or numeric: elements to use (all by default)}

\item{clinical}{Data frame: clinical data}

\item{...}{Arguments passed on to \code{processSurvTerms}
\describe{
  \item{censoring}{Character: censor using "left", "right", "interval" or
"interval2"}
  \item{scale}{Character: rescale the survival time to "days", "weeks",
"months" or "years"}
  \item{formulaStr}{Character: formula to use}
  \item{coxph}{Boolean: fit a Cox proportional hazards regression model? FALSE 
by default}
  \item{survTime}{survTime object: times to follow up, time start, time stop
and event (optional)}
  \item{event}{Character: name of column containing time of the event of
interest}
  \item{timeStart}{Character: name of column containing starting time of the
interval or follow up time}
  \item{timeStop}{Character: name of column containing ending time of the 
interval (only relevant for interval censoring)}
  \item{followup}{Character: name of column containing follow up time}
}}

\item{session}{Shiny session}

\item{survivalInfo}{Boolean: return extra survival information}
}
\value{
p-value of the survival difference
}
\description{
Test the survival difference between two survival groups given a cutoff
}
