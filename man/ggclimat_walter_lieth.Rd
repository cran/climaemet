% Generated by roxygen2: do not edit by hand
% Please edit documentation in R/climatogram.R
\name{ggclimat_walter_lieth}
\alias{ggclimat_walter_lieth}
\title{Walter and Lieth climatic diagram on \CRANpkg{ggplot2}}
\usage{
ggclimat_walter_lieth(
  dat,
  est = "",
  alt = NA,
  per = NA,
  mlab = "es",
  pcol = "#002F70",
  tcol = "#ff0000",
  pfcol = "#9BAEE2",
  sfcol = "#3C6FC4",
  shem = FALSE,
  p3line = FALSE,
  ...
)
}
\arguments{
\item{dat}{Monthly climatic data for which the diagram will be plotted.}

\item{est}{Name of the climatological station.}

\item{alt}{Altitude of the climatological station.}

\item{per}{Period on which the averages have been computed.}

\item{mlab}{Month labels for the X axis. Use 2-digit language code (\code{"en"},
\code{"es"}, etc.). See \code{\link[readr:locale]{readr::locale()}} for info.}

\item{pcol}{Color for precipitation.}

\item{tcol}{Color for temperature.}

\item{pfcol}{Fill color for probable frosts.}

\item{sfcol}{Fill color for sure frosts.}

\item{shem}{Set to \code{TRUE} for southern hemisphere stations.}

\item{p3line}{Set to \code{TRUE} to draw a supplementary precipitation line
referenced to three times the temperature (as suggested by Bogdan Rosca).}

\item{...}{Other graphic parameters}
}
\value{
A \CRANpkg{ggplot2} object. See \code{help("ggplot2")}.
}
\description{
Plot of a Walter and Lieth climatic diagram of a station. This function is
an updated version of \code{\link[climatol:diagwl]{climatol::diagwl()}}, by Jose A. Guijarro.

\if{html}{\figure{lifecycle-experimental.svg}{options: alt="[Experimental]"}}
}
\details{
See Details on \code{\link[climatol:diagwl]{climatol::diagwl()}}.

Climatic data must be passed as a 4x12 matrix or \code{data.frame} of monthly
(January to December) data, in the following order:
\itemize{
\item Row 1: Mean precipitation.
\item Row 2: Mean maximum daily temperature.
\item Row 3: Mean minimum daily temperature.
\item Row 4: Absolute monthly minimum temperature.
}

See \link{climaemet_9434_climatogram} for a sample dataset.
}
\section{API Key}{
You need to set your API Key globally using \code{\link[=aemet_api_key]{aemet_api_key()}}.
}

\examples{

library(ggplot2)

wl <- ggclimat_walter_lieth(
  climaemet::climaemet_9434_climatogram,
  alt = "249",
  per = "1981-2010",
  est = "Zaragoza Airport"
)

wl

# As it is a ggplot object we can modify it

wl + theme(
  plot.background = element_rect(fill = "grey80"),
  panel.background = element_rect(fill = "grey70"),
  axis.text.y.left = element_text(
    colour = "black",
    face = "italic"
  ),
  axis.text.y.right = element_text(
    colour = "black",
    face = "bold"
  )
)
}
\references{
\itemize{
\item Walter, H. K., Harnickell, E., Lieth, F. H. H., & Rehder, H. (1967).
\emph{Klimadiagramm-weltatlas}. Jena: Fischer, 1967.
}
}
\seealso{
\code{\link[climatol:diagwl]{climatol::diagwl()}}, \code{\link[readr:locale]{readr::locale()}}

Other aemet_plots: 
\code{\link{climatestripes_station}()},
\code{\link{climatogram_normal}()},
\code{\link{climatogram_period}()},
\code{\link{ggstripes}()},
\code{\link{ggwindrose}()},
\code{\link{windrose_days}()},
\code{\link{windrose_period}()}

Other climatogram: 
\code{\link{climaemet_9434_climatogram}},
\code{\link{climatogram_normal}()},
\code{\link{climatogram_period}()}
}
\concept{aemet_plots}
\concept{climatogram}
