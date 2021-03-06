% Generated by roxygen2: do not edit by hand
% Please edit documentation in R/climaemet_main.R
\name{climatogram_period}
\alias{climatogram_period}
\title{Walter & Lieth climatic diagram for a time period}
\usage{
climatogram_period(
  station,
  apikey,
  start = 1990,
  end = 2020,
  labels = c("en", "es", "")
)
}
\arguments{
\item{station}{Character string as station identifier code (see \code{\link{aemet_stations}}).}

\item{apikey}{Character string as personal API key (see \url{https://opendata.aemet.es/centrodedescargas/obtencionAPIKey}).}

\item{start}{Numeric value as start year (format: \%Y).}

\item{end}{Numeric value as end year (format: \%Y).}

\item{labels}{Character string as month labels for the X axis: "en" (english), "es" (spanish) or blank (numeric labels, 1-12).}
}
\value{
a plot.
}
\description{
Plot of a Walter & Lieth climatic diagram from monthly climatology data for a station. This climatogram are great for showing a summary of climate conditions for a place over a specific time period.
}
\note{
The code is based on code from the CRAN package "climatol" by Jose A. Guijarro \href{mailto:jguijarrop@aemet.es}{jguijarrop@aemet.es}.
}
\examples{
\dontrun{
climatogram_period(station, apikey, start = 1990, end = 2020, labels = "en")
}

}
\references{
Walter, H. & Lieth, H (1960): Klimadiagramm Weltatlas. G. Fischer, Jena.
}
\seealso{
See more details in the "diagwl" function \code{\link[climatol]{diagwl}}.
}
