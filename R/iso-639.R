#' Convert to and from ISO 639 language code
#'
#' @param lang Name of the language to be converted
#' @export
to_iso639 <- function(lang) {
  codes <- readRDS(system.file("iso/codes.rds", package = "lang"))
  lang <- tolower(lang)
  match <- codes[codes$name == lang, "code"]
  if (nrow(match) > 0) {
    out <- as.character(match)[[1]]
  } else {
    out <- NULL
  }
  out
}

#' @rdname to_iso639
#' @param iso The two-letter ISO 639 code to search
from_iso639 <- function(iso) {
  codes <- readRDS(system.file("iso/codes.rds", package = "lang"))
  iso <- tolower(iso)
  match <- codes[codes$code == iso,]
  if (nrow(match) > 0) {
    out <- match$name
  } else {
    out <- NULL
  }
  out
}
