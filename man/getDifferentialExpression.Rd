% Generated by roxygen2: do not edit by hand
% Please edit documentation in R/globalAccess.R
\name{getDifferentialExpression}
\alias{getDifferentialExpression}
\alias{setDifferentialExpression}
\alias{getDifferentialExpressionFiltered}
\alias{setDifferentialExpressionFiltered}
\alias{getDifferentialExpressionSurvival}
\alias{setDifferentialExpressionSurvival}
\alias{getDifferentialExpressionResetPaging}
\alias{setDifferentialExpressionResetPaging}
\alias{getDifferentialExpressionColumns}
\alias{setDifferentialExpressionColumns}
\title{Get or set differential expression' elements for a data category}
\usage{
getDifferentialExpression(category = getCategory())

setDifferentialExpression(differential, category = getCategory())

getDifferentialExpressionFiltered(category = getCategory())

setDifferentialExpressionFiltered(differential, category = getCategory())

getDifferentialExpressionSurvival(category = getCategory())

setDifferentialExpressionSurvival(survival, category = getCategory())

getDifferentialExpressionResetPaging(category = getCategory())

setDifferentialExpressionResetPaging(reset, category = getCategory())

getDifferentialExpressionColumns(category = getCategory())

setDifferentialExpressionColumns(columns, category = getCategory())
}
\arguments{
\item{category}{Character: data category (e.g. "Carcinoma 2016"); by default,
it uses the selected data category}

\item{differential}{Data frame or matrix: differential analyses table}

\item{survival}{Data frame or matrix: differential analyses' survival data}

\item{reset}{Character: reset paging of differential analyses table?}

\item{columns}{Character: differential analyses' column names}
}
\value{
Getters return globally accessible data, whereas setters return NULL 
as they are only used to modify the Shiny session's state
}
\description{
Get or set differential expression' elements for a data category
}
\seealso{
\code{\link{getEvent}}, \code{\link{getClinicalMatchFrom}},
\code{\link{getGroups}} and \code{\link{getDifferentialSplicing}}
}
