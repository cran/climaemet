#' Forecast database by municipality
#'
#' Get a database of daily or hourly weather forecasts for a given municipality.
#'
#' @family aemet_api_data
#' @family forecasts
#'
#' @param x A vector of municipality codes to extract. For convenience,
#'   \pkg{climaemet} provides this data on the dataset [aemet_munic]
#'   (see `municipio` field) as of January 2020.
#' @inheritParams get_data_aemet
#'
#' @inheritSection aemet_daily_clim API Key
#'
#' @return A nested `tibble`. Forecasted values can be extracted with
#'   [aemet_forecast_tidy()]. See also **Details**
#'
#' @export
#' @rdname aemet_forecast
#' @seealso [aemet_munic] for municipality codes.
#'
#' @details
#'
#' Forecasts format provided by the AEMET API have a complex structure.
#' Although \pkg{climaemet} returns a `tibble`, each forecasted value is
#' provided as a nested `tibble`. [aemet_forecast_tidy()] helper function can
#' unnest these values an provide a single unnested `tibble` for the requested
#' variable.
#'
#' @examplesIf aemet_detect_api_key()
#'
#' # Select a city
#' data("aemet_munic")
#' library(dplyr)
#' munis <- aemet_munic %>%
#'   filter(municipio_nombre %in% c(
#'     "Santiago de Compostela",
#'     "Lugo"
#'   )) %>%
#'   pull(municipio)
#'
#' daily <- aemet_forecast_daily(munis)
#'
#' # Vars available
#' aemet_forecast_vars_available(daily)
#'
#'
#' # This is nested
#' daily %>%
#'   select(municipio, fecha, nombre, temperatura)
#'
#' # Select and unnest
#' daily_temp <- aemet_forecast_tidy(daily, "temperatura")
#'
#' # This is not
#' daily_temp
#'
#' # Wrangle and plot
#' daily_temp_end <- daily_temp %>%
#'   select(
#'     elaborado, fecha, municipio, nombre, temperatura_minima,
#'     temperatura_maxima
#'   ) %>%
#'   tidyr::pivot_longer(cols = contains("temperatura"))
#'
#' # Plot
#' library(ggplot2)
#' ggplot(daily_temp_end) +
#'   geom_line(aes(fecha, value, color = name)) +
#'   facet_wrap(~nombre, ncol = 1) +
#'   scale_color_manual(
#'     values = c("red", "blue"),
#'     labels = c("max", "min")
#'   ) +
#'   scale_x_date(
#'     labels = scales::label_date_short(),
#'     breaks = "day"
#'   ) +
#'   scale_y_continuous(
#'     labels = scales::label_comma(suffix = "º")
#'   ) +
#'   theme_minimal() +
#'   labs(
#'     x = "", y = "",
#'     color = "",
#'     title = "Forecast: 7-day temperature",
#'     subtitle = paste(
#'       "Forecast produced on",
#'       format(daily_temp_end$elaborado[1], usetz = TRUE)
#'     )
#'   )
aemet_forecast_hourly <- function(x, verbose = FALSE) {
  single <- lapply(x, function(x) {
    res <- try(aemet_forecast_hourly_single(x, verbose = verbose),
      silent = TRUE
    )
    if (inherits(res, "try-error")) {
      message(
        "\nAEMET API call for '", x, "' returned an error\n",
        "Return NULL for this query"
      )
      return(NULL)
    }
    return(res)
  })
  bind <- dplyr::bind_rows(single)
  # Preserve format
  bind$id <- sprintf("%05d", as.numeric(bind$id))
  bind <- aemet_hlp_guess(bind, preserve = c("id", "municipio"))
  return(bind)
}

aemet_forecast_hourly_single <- function(x, verbose = FALSE) {
  if (is.numeric(x)) x <- sprintf("%05d", x)

  pred <-
    get_data_aemet(
      apidest = paste0("/api/prediccion/especifica/municipio/horaria/", x),
      verbose = verbose
    )


  pred$elaborado <- as.POSIXct(gsub("T", " ", pred$elaborado),
    tz = "Europe/Madrid"
  )

  # Unnesting this dataset is complex
  col_types <- get_col_first_class(pred)
  vars <- names(col_types[col_types %in% c("list", "data.frame")])

  first_lev <- tidyr::unnest(pred,
    col = dplyr::all_of(vars), names_sep = "_",
    keep_empty = TRUE
  )

  # Extract prediccion dia
  pred_dia <- first_lev$prediccion_dia[[1]]
  pred_dia <- tibble::as_tibble(pred_dia)
  pred_dia$fecha <- as.Date(pred_dia$fecha)
  master <- first_lev[, names(first_lev) != "prediccion_dia"]
  master_end <- dplyr::bind_cols(master, pred_dia)

  # Add initial id
  master_end$municipio <- x
  master_end <- dplyr::relocate(master_end, dplyr::all_of("municipio"),
    .before = dplyr::all_of("nombre")
  )


  return(master_end)
}