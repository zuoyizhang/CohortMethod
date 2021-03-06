% Generated by roxygen2 (4.1.0): do not edit by hand
% Please edit documentation in R/OutcomeModels.R
\name{plotKaplanMeier}
\alias{plotKaplanMeier}
\title{Plot the Kaplan-Meier curve}
\usage{
plotKaplanMeier(outcomeModel, censorMarks = FALSE,
  confidenceIntervals = TRUE, includeZero = TRUE, dataCutoff = 0.99,
  treatmentLabel = "Treated", comparatorLabel = "Comparator",
  fileName = NULL)
}
\arguments{
\item{outcomeModel}{An object of type \code{outcomeModel} as generated using he \code{fitOutcomeModel} function.}

\item{censorMarks}{Whether or not to include censor marks in the plot.}

\item{confidenceIntervals}{Plot 95 percent confidence intervals?}

\item{includeZero}{Should the y axis include zero, or only go down to the lowest observed survival?}

\item{dataCutoff}{Fraction of the data (number censored) after which the graph will not be shown.}

\item{treatmentLabel}{A label to us for the treated cohort.}

\item{comparatorLabel}{A label to us for the comparator cohort.}

\item{fileName}{Name of the file where the plot should be saved, for example 'plot.png'. See
the function \code{ggsave} in the ggplot2 package for supported file formats.}
}
\value{
A ggplot object. Use the \code{\link[ggplot2]{ggsave}} function to save to file in a different format.
}
\description{
\code{plotKaplanMeier} creates the Kaplain-Meier survival plot
}
\examples{
#todo
}

