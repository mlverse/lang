roxygen_translate <- function(path, lang = NULL, dir = fs::path("man-lang", lang)) {
  path <- "~/Projects/mall/r/R/llm-classify.R"
  lang <- "fr"
  dir <- fs::path("man-lang", lang)
  dir_create(dir)
  if (is_file(path)) {
    rd_path <- path(dir, path_file(path))
    parsed <- roxygen2::parse_file(path)
    contents <- NULL
    for (roxy in parsed) {
      for (tag in roxy$tags) {
        translation <- llm_vec_translate(tag$raw, language = lang)
        # translation <- tag$raw
        if (tag$tag != "title") {
          contents <- c(contents, glue("#' @{tag$tag} {translation}"))
        } else {
          contents <- c(contents, glue("#' {translation}"))
        }
      }
      contents <- c(contents, glue("{roxy$object$alias} <- function(...) NULL"))
    }
    writeLines(contents, rd_path)
  }
}
