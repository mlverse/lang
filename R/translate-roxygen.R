#' Translates the Roxygen2 documentation 
#' @description
#' Reads the Roxygen2 tags in the package and translates them. The translations 
#' are stored in R scripts. The default location of the new scripts is 'man-lang'.
#' The will be in a sub-folder representing the language the are translated to.
#'
#' @details This approach makes it easier to edit the translations by hand after
#' the LLM does a first pass. This way it is easier for others to collaborate
#' with improving the translation
#' 
#' @param lang 2-letter target language to translate to
#' @param path The source R scripts. This can be a folder or a single file. It
#' defaults to the R folder.
#' @param dir The target folder to save the new, translated, R scripts to. It
#' defaults to 'man-lan/[2 letter target language]'
#' 
#' @export
roxygen_translate <- function(lang = NULL, path = "R", dir = fs::path("man-lang", lang)) {
  dir <- fs::path("man-lang", lang)
  dir_create(dir)
  if (is_dir(path)) {
    r_files <- dir_ls(path, glob = "*.R")
    for (files in r_files) {
      roxygen_translate_file(path = files, lang = lang, dir = dir)
    }
  } else {
    roxygen_translate_file(path = path, lang = lang, dir = dir)
  }
}

roxygen_translate_file <- function(path, lang = NULL, dir = fs::path("man-lang", lang)) {
  cli_inform("Translating: {path}")
  rd_path <- path(dir, path_file(path))
  parsed <- roxygen2::parse_file(path)
  contents <- NULL
  for (roxy in parsed) {
    for (tag in roxy$tags) {
      raw <- tag$raw
      if (tag$tag %in% c("title", "description", "param", "details", "returns")) {
        raw <- llm_vec_translate(raw, language = lang)
      }
      raw <- gsub("\n", "\n#'", raw)
      if (tag$tag == "title") {
        contents <- c(contents, glue("#' {raw}"))
      } else {
        contents <- c(contents, glue("#' @{tag$tag} {raw}"))
      }
    }
    contents <- c(contents, glue("{roxy$object$alias} <- function(...) NULL"))
  }
  if (!is.null(contents)) {
    writeLines(contents, rd_path)
  }
}
