# API Functions: This functions makes a direct call to the API

#' Client tool for AEMET API
#'
#' Client tool to get data and metadata from AEMET and convert json to tibble.
#'
#' @family aemet_api
#'
#' @source <https://opendata.aemet.es/dist/index.html>
#'
#' @param apidest Character string as destination URL. See
#'   <https://opendata.aemet.es/dist/index.html>.
#'
#' @param verbose Logical `TRUE/FALSE`. Provides information about the flow of
#' information between the client and server.
#'
#'
#' @return
#' A tibble (if possible) or the results of the query as provided by
#' [httr::content()].
#'
#' @seealso
#' Some examples on how to use these functions on
#' `vignette("extending-climaemet")`.
#'
#' @examplesIf aemet_detect_api_key()
#' # Run this example only if AEMET_API_KEY is detected
#'
#' url <- "/api/valores/climatologicos/inventarioestaciones/todasestaciones"
#'
#' get_data_aemet(url)
#'
#'
#' # Metadata
#'
#' get_metadata_aemet(url)
#'
#' # We can get data from any API endpoint
#'
#' # Plain text
#'
#' plain <- get_data_aemet("/api/prediccion/nacional/hoy")
#'
#' cat(plain)
#'
#' # An image
#'
#' image <- get_data_aemet("/api/mapasygraficos/analisis")
#'
#' # Write and read
#' tmp <- tempfile(fileext = ".gif")
#'
#' writeBin(image, tmp)
#'
#' gganimate::gif_file(tmp)
#' @export
get_data_aemet <- function(apidest, verbose = FALSE) {
  # API Key management
  apikey_detected <- aemet_detect_api_key()
  if (isFALSE(apikey_detected)) {
    stop("API key can't be missing. See ??aemet_api_key.", call. = FALSE)
  }
  apikey <- Sys.getenv("AEMET_API_KEY")


  stopifnot(is.logical(verbose))
  url_base <- "https://opendata.aemet.es/opendata"

  url1 <- paste0(url_base, apidest)

  if (verbose) {
    message("\nRequesting ", url1)
  }


  # 1. Call: Get path----
  response <- httr::GET(url1, httr::add_headers(api_key = apikey))

  status <- httr::status_code(response)
  headers <- httr::headers(response)

  delay_aemet_api(headers$`remaining-request-count`)

  # Retrieve status after call - sometimes the status is in the header
  if (!is.null(headers$aemet_estado)) {
    status <- as.integer(headers$aemet_estado)
  }

  # On 401 stop, invalid API Key
  if (status == 401) {
    message("API Key Not Valid. Try with a new one.")
    httr::stop_for_status(status)
  }

  # On timeout retry
  if (status %in% c(429, 500)) {
    response <- httr::RETRY("GET", url1, httr::add_headers(api_key = apikey),
      quiet = !verbose,
      pause_min = 30, pause_base = 30, pause_cap = 60
    )
  }

  status <- httr::status_code(response)
  headers <- httr::headers(response)
  if (!is.null(headers$aemet_estado)) {
    status <- as.integer(headers$aemet_estado)
  }
  if (verbose) {
    httr::message_for_status(status)
    message(headers$aemet_mensaje)
  }

  # Status handling: Valid 200, Invalid 401, The rest are empty,
  if (status == 401) {
    message("API Key Not Valid. Try with a new one.")
    httr::stop_for_status(status)
  } else if (status != 200) {
    # Return NULL value
    msg <- "Something went wrong"
    if (!is.null(headers$aemet_mensaje)) {
      msg <- headers$aemet_mensaje
    }
    httr::message_for_status(status)
    message() # Create new line
    warning("With: ", apidest, ": ", msg, call. = FALSE)

    return(NULL)
  }

  results <- httr::content(response, as = "text", encoding = "UTF-8")

  # On error when parsing return NULL
  if (isFALSE(jsonlite::validate(results))) {
    warning("Error parsing JSON. Returning empty line, check your results")
    return(NULL)
  }

  # OK, valid
  if (verbose) {
    httr::message_for_status(status)
    message(headers$aemet_mensaje)
  }

  data_tibble <- jsonlite::fromJSON(results)
  data_tibble <- tibble::as_tibble(data_tibble)

  # 2. Get data from first call----
  if (verbose) {
    message("-----Requesting data-----")
    message("Requesting ", data_tibble$datos)
  }
  rm(status, response, headers)

  # Initialise status for the loop
  response_data <- httr::GET(data_tibble$datos)

  # Retrieve status after call
  status_data <- httr::status_code(response_data)
  headers_data <- httr::headers(response_data)

  # On timeout still 429, wait and rerun
  if (status_data %in% c(429, 500)) {
    response_data <- httr::RETRY("GET", data_tibble$datos,
      quiet = !verbose,
      pause_min = 30, pause_base = 30, pause_cap = 60
    )
  }

  status_data <- httr::status_code(response_data)
  headers_data <- httr::headers(response_data)

  if (verbose) {
    message(
      "Remaining requests: ",
      headers_data$`remaining-request-count`
    )
  }

  delay_aemet_api(headers_data$`remaining-request-count`)

  # Status handling: Valid 200, Invalid 401, The rest are empty,
  if (status_data == 401) {
    message("API Key Not Valid. Try with a new one.")
    httr::stop_for_status(status_data)
  } else if (status_data != 200) {
    # Return NULL value
    if (!is.null(headers_data$aemet_mensaje)) {
      message(headers_data$aemet_mensaje)
    }
    httr::warn_for_status(status_data)
    return(NULL)
  }

  if (verbose) {
    httr::message_for_status(status_data)
    message(headers_data$aemet_mensaje)
  }

  results_data <- httr::content(response_data)

  data_tibble_end <- tryCatch(
    {
      tibble::as_tibble(jsonlite::fromJSON(results_data))
    },
    error = function(e) {
      message(
        "\nReturning raw results. MIME type: ",
        httr::http_type(response_data),
        "\n"
      )
      return(results_data)
    }
  )

  return(data_tibble_end)
}

#' @rdname get_data_aemet
#' @name get_data_aemet
#' @export
get_metadata_aemet <- function(apidest, verbose = FALSE) {
  # API Key management
  apikey_detected <- aemet_detect_api_key()
  if (isFALSE(apikey_detected)) {
    stop("API key can't be missing. See ??aemet_api_key.", call. = FALSE)
  }
  apikey <- Sys.getenv("AEMET_API_KEY")


  stopifnot(is.logical(verbose))
  url_base <- "https://opendata.aemet.es/opendata"

  url1 <- paste0(url_base, apidest)

  if (verbose) {
    message("\nRequesting ", url1)
  }


  # 1. Call: Get path----
  response <- httr::GET(url1, httr::add_headers(api_key = apikey))

  status <- httr::status_code(response)
  headers <- httr::headers(response)

  delay_aemet_api(headers$`remaining-request-count`)

  # Retrieve status after call - sometimes the status is in the header
  if (!is.null(headers$aemet_estado)) {
    status <- as.integer(headers$aemet_estado)
  }

  # On 401 stop, invalid API Key
  if (status == 401) {
    message("API Key Not Valid. Try with a new one.")
    httr::stop_for_status(status)
  }

  # On timeout retry
  if (status %in% c(429, 500)) {
    response <- httr::RETRY("GET", url1, httr::add_headers(api_key = apikey),
      quiet = !verbose,
      pause_min = 30, pause_base = 30, pause_cap = 60
    )
  }

  status <- httr::status_code(response)
  headers <- httr::headers(response)
  if (!is.null(headers$aemet_estado)) {
    status <- as.integer(headers$aemet_estado)
  }
  if (verbose) {
    httr::message_for_status(status)
    message(headers$aemet_mensaje)
  }

  # Status handling: Valid 200, Invalid 401, The rest are empty,
  if (status == 401) {
    message("API Key Not Valid. Try with a new one.")
    httr::stop_for_status(status)
  } else if (status != 200) {
    # Return NULL value
    msg <- "Something went wrong"
    if (!is.null(headers$aemet_mensaje)) {
      msg <- headers$aemet_mensaje
    }
    httr::message_for_status(status)
    message() # Create new line
    warning("With: ", apidest, ": ", msg, call. = FALSE)

    return(NULL)
  }

  results <- httr::content(response, as = "text", encoding = "UTF-8")

  # On error when parsing return NULL
  if (isFALSE(jsonlite::validate(results))) {
    warning("Error parsing JSON. Returning empty line, check your results")
    return(NULL)
  }

  # OK, valid
  if (verbose) {
    httr::message_for_status(status)
    message(headers$aemet_mensaje)
  }

  data_tibble <- jsonlite::fromJSON(results)
  data_tibble <- tibble::as_tibble(data_tibble)

  # 2. Get data from first call----
  if (verbose) {
    message("-----Requesting data-----")
    message("Requesting ", data_tibble$metadatos)
  }
  rm(status, response, headers)

  # Initialise status for the loop
  response_data <- httr::GET(data_tibble$metadatos)

  # Retrieve status after call
  status_data <- httr::status_code(response_data)
  headers_data <- httr::headers(response_data)

  # On timeout still 429, wait and rerun
  if (status_data %in% c(429, 500)) {
    response_data <- httr::RETRY("GET", data_tibble$metadatos,
      quiet = !verbose,
      pause_min = 30, pause_base = 30, pause_cap = 60
    )
  }

  status_data <- httr::status_code(response_data)
  headers_data <- httr::headers(response_data)

  if (verbose) {
    message(
      "Remaining requests: ",
      headers_data$`remaining-request-count`
    )
  }

  delay_aemet_api(headers_data$`remaining-request-count`)

  # Status handling: Valid 200, Invalid 401, The rest are empty,
  if (status_data == 401) {
    message("API Key Not Valid. Try with a new one.")
    httr::stop_for_status(status_data)
  } else if (status_data != 200) {
    # Return NULL value
    if (!is.null(headers_data$aemet_mensaje)) {
      message(headers_data$aemet_mensaje)
    }
    httr::warn_for_status(status_data)
    return(NULL)
  }

  if (verbose) {
    httr::message_for_status(status_data)
    message(headers_data$aemet_mensaje)
  }

  results_data <- httr::content(response_data)

  data_tibble_end <- tryCatch(
    {
      s <- jsonlite::fromJSON(results_data)
      this <- vapply(s, length, FUN.VALUE = numeric(1)) > 0
      tibble::as_tibble(s[this])
    },
    error = function(e) {
      return(results_data)
    }
  )

  return(data_tibble_end)
}

# Add some delay based on the response of the header
delay_aemet_api <- function(counts) {
  # See remaining requests and add delay (avoid throttling of the API)
  remain <- as.integer(counts)
  if (any(is.na(remain), is.null(remain), length(remain) == 0)) {
    return(NULL)
  }

  if (remain < 105) {
    Sys.sleep(5)
  }
  if (remain %in% seq(105, 120)) {
    Sys.sleep(1)
  }
  if (remain %in% seq(120, 130)) {
    Sys.sleep(0.25)
  }
  return(NULL)
}
