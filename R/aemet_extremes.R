# valores-climatologicos
# https://opendata.aemet.es/dist/index.html#/

#' Extreme values for a station
#'
#' Get recorded extreme values for a station.
#'
#' @family aemet_api_data
#'
#' @param station Character string with station identifier code(s)
#'   (see [aemet_stations()])
#'
#' @param parameter Character string as temperature ("T"),
#'   precipitation ("P") or wind ("V") parameter.
#'
#' @inheritParams aemet_last_obs
#'
#' @inheritSection aemet_daily_clim API Key
#'
#' @seealso [aemet_api_key()]
#' @return A \CRANpkg{tibble} or a \CRANpkg{sf} object
#'
#' @examplesIf aemet_detect_api_key()
#' library(tibble)
#' obs <- aemet_extremes_clim(c("9434", "3195"))
#' glimpse(obs)
#' @export

aemet_extremes_clim <- function(station = NULL, parameter = "T",
                                verbose = FALSE, return_sf = FALSE,
                                extract_metadata = FALSE) {
  # Validate parameters----
  if (is.null(station)) {
    stop("Station can't be missing")
  }

  station <- as.character(station)

  if (isTRUE(extract_metadata)) station <- station[1]

  if (is.null(parameter)) {
    stop("Parameter can't be missing")
  }

  if (!is.character(parameter)) {
    stop("Parameter need to be character string")
  }

  if (!parameter %in% c("T", "P", "V")) {
    stop("Parameter should be one of 'T', 'P', 'V'")
  }

  # Single request----
  # Vectorize function
  final_result <- NULL

  for (i in seq_len(length(station))) {
    apidest <-
      paste0(
        "/api/valores/climatologicos/valoresextremos/parametro/",
        parameter,
        "/estacion/",
        station[i]
      )

    if (isTRUE(extract_metadata)) {
      final_result <- get_metadata_aemet(
        apidest = apidest,
        verbose = verbose
      )
    } else {
      final_result <-
        dplyr::bind_rows(
          final_result,
          get_data_aemet(apidest, verbose)
        )
    }
  }

  final_result <- dplyr::distinct(final_result)
  if (isTRUE(extract_metadata)) {
    return(final_result)
  }

  # Guess formats
  final_result <-
    aemet_hlp_guess(final_result, "indicativo", dec_mark = ".")
  # Check spatial----
  if (return_sf) {
    # Coordinates from stations
    sf_stations <-
      aemet_stations(verbose, return_sf = FALSE)
    sf_stations <-
      sf_stations[c("indicativo", "latitud", "longitud")]

    final_result <-
      dplyr::left_join(final_result, sf_stations, by = "indicativo")
    final_result <-
      aemet_hlp_sf(final_result, "latitud", "longitud", verbose)
  }

  return(final_result)
}
