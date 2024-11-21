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
