#' @title climaemet_news
#'
#' @description Show the NEWS file of the \CRANpkg{climaemet} package.
#'
#' @family helpers
#'
#' @details (See description)
#'
#' @return Open NEWS from `climaemet`.
#'
#' @export
#'
#' @examples
#' \dontrun{
#' climaemet_news()
#' }
#'
climaemet_news <- function() {
  # nocov start
  file <- file.path(system.file(package = "climaemet"), "NEWS.md")
  file.show(file)
  # nocov end
}
