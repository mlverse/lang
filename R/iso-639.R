#' Convert to and from ISO 639 language code
#'
#' @param lang Name of the language to be converted
#' @param silent Flag to indicate if the function should return a message
#' with the result. If there is no match, it will be an error message
#' @export
to_iso639 <- function(lang, silent = TRUE) {
  codes <- readRDS(system.file("iso/codes.rds", package = "lang"))
  lang <- tolower(lang)
  match <- codes[codes$name == lang, "code"]
  if (nrow(match) > 0) {
    out <- as.character(match)[[1]]
    if (!silent) {
      cli_alert_success("'{lang}' converted to ISO 639 code: '{out}'")
    }
  } else {
    if (!silent) {
      cli_abort("'{lang}' could not be matched to an ISO 639 code")
    }
  }
  out
}

#' @rdname to_iso639
#' @param iso The two-letter ISO 639 code to search
from_iso639 <- function(iso) {
  codes <- readRDS(system.file("iso/codes.rds", package = "lang"))
  iso <- tolower(iso)
  match <- codes[codes$code == iso, ]
  if (nrow(match) > 0) {
    out <- match$name
  } else {
    out <- NULL
  }
  out
}
