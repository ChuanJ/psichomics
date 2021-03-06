% Generated by roxygen2: do not edit by hand
% Please edit documentation in R/analysis_information.R
\name{renderGeneticInfo}
\alias{renderGeneticInfo}
\title{Render genetic information}
\usage{
renderGeneticInfo(output, ns, info, species = NULL, assembly = NULL,
  grch37 = FALSE)
}
\arguments{
\item{output}{Shiny output}

\item{ns}{Namespace function}

\item{info}{Information as retrieved from Ensembl}

\item{species}{Character: species name (NULL by default)}

\item{assembly}{Character: assembly version (NULL by default)}

\item{grch37}{Boolean: use version GRCh37 of the genome? FALSE by default}
}
\value{
HTML elements to render gene, protein and transcript annotation
}
\description{
Render genetic information
}
