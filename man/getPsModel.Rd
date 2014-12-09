% Generated by roxygen2 (4.0.2): do not edit by hand
\name{getPsModel}
\alias{getPsModel}
\title{Get the propensity model}
\usage{
getPsModel(propensityScore, cohortData)
}
\arguments{
\item{propensityScore}{The propensity scores as generated using the \code{createPs} function.}

\item{cohortData}{An object of type \code{cohortData} as generated using \code{getDbCohortData}.}
}
\description{
\code{getPsModel} shows the propensity score model
}
\details{
Shows the coefficients and names of the covariates with non-zero coefficients.
}
\examples{
#todo
}
