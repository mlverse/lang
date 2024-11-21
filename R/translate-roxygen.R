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
translate_roxygen <- function(
    lang = NULL,
    path = "R",
    dir = fs::path("man-lang", lang)) {
  if (nchar(lang) != 2) {
    cli_abort("Use an ISO 639 2 character language code for `lang`")
  }
  dir <- fs::path("man-lang", lang)
  dir_create(dir)
  if (is_dir(path)) {
    cli_h3("`lang` translating Roxygen into '{lang}'")
    r_files <- dir_ls(path, glob = "*.R")
    for (i in seq_along(r_files)) {
      translate_roxygen_file(
        path = r_files[[i]],
        lang = lang,
        dir = dir,
        no = i,
        of = length(r_files)
      )
    }
  } else {
    translate_roxygen_file(path = path, lang = lang, dir = dir)
  }
}

translate_roxygen_file <- function(path, lang = NULL, dir, no = 1, of = 1) {
  rd_path <- path(dir, path_file(path))
  cli_inform("[{no}/{of}] {path} --> {rd_path}")
  parsed <- roxygen2::parse_file(path)
  contents <- NULL
  for (roxy in parsed) {
    tg <- NULL
    cli_progress_message("Translating: {.emph {tg}}")
    for (tag in roxy$tags) {
      tg <- tag$tag
      raw <- tag$raw
      if (tg %in% c("title", "description", "param", "details", "returns")) {
        cli_progress_update()
        raw <- llm_vec_translate(raw, language = lang)
      }
      if (tg == "param") {
        name <-  glue(" tag$val$name ")
      } else {
        name <- ""
      }
      raw <- gsub("\n", "\n#'", raw)
      if (tg == "title") {
        contents <- c(contents, glue("#' {raw}"))
      } else {
        contents <- c(contents, glue("#' @{tg} {name} {raw}"))
      }
    }
    contents <- c(contents, glue("{roxy$object$alias} <- function(...) NULL"))
  }
  if (!is.null(contents)) {
    writeLines(contents, rd_path)
  }
}
