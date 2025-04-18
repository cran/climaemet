#' Converts `dms` format to decimal degrees
#'
#' Converts degrees, minutes and seconds to decimal degrees.
#'
#' @family helpers
#'
#'
#' @rdname dms2decdegrees
#'
#' @note
#'
#' Code for `dms2decdegrees()` modified from project
#' <https://github.com/SevillaR/aemet>.
#'
#' @param input Character string as `dms` coordinates.
#'
#' @return A numeric value.
#'
#' @examples
#' dms2decdegrees("055245W")
#' @export
dms2decdegrees <- function(input = NULL) {
  if (is.null(input)) {
    stop("Input can't be missing")
  }

  if (!is.character(input)) {
    stop("Input need to be character string")
  }

  deg <- as.numeric(substr(input, 0, 2))
  min <- as.numeric(substr(input, 3, 4))
  sec <- as.numeric(substr(input, 5, 6))
  x <- deg + min / 60 + sec / 3600
  x <- ifelse(substr(input, 7, 8) == "W", -x, x)
  x <- ifelse(substr(input, 7, 8) == "S", -x, x)

  return(x)
}

#' @rdname dms2decdegrees
#' @export
#' @examples
#' dms2decdegrees_2("-3º 40' 37\"")
dms2decdegrees_2 <- function(input = NULL) {
  input_2 <- iconv(input, "latin1", "ASCII", sub = " ")
  minus <- ifelse(grepl("^-", input_2), -1, 1)
  # Remove now signs
  input_3 <- gsub("[^0-9]", " ", input_2)

  pieces <- unlist(strsplit(input_3, split = " "))
  pieces <- as.double(pieces[pieces != ""])

  # Check here
  if (length(pieces) != 3) stop("Something went wrong")


  # Convert pieces and sign
  dec <- minus * sum(pieces / c(1, 60, 60^2))

  dec
}

#' First and last day of year
#'
#' Get first and last day of year.
#'
#' @rdname day_of_year
#'
#' @family helpers
#'
#' @param year Numeric value as year (format: YYYY).
#'
#' @return Character string as date (format: YYYY-MM-DD).
#'
#' @examples
#' first_day_of_year(2000)
#' last_day_of_year(2020)
#' @export


first_day_of_year <- function(year = NULL) {
  if (is.null(year)) {
    stop("Year can't be missing")
  }

  if (!is.numeric(year)) {
    stop("Year need to be numeric")
  }

  date <- as.character(paste0(year, "-01-01"))

  return(date)
}

#' @rdname day_of_year
#' @export
last_day_of_year <- function(year = NULL) {
  if (is.null(year)) {
    stop("Year can't be missing")
  }

  if (!is.numeric(year)) {
    stop("Year need to be numeric")
  }

  date <- as.character(paste0(year, "-12-31"))

  return(date)
}
