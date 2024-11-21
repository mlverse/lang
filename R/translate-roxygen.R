roxygen_translate <- function(path, lang = NULL, dir = fs::path("man-lang", lang)) {
  path <- "R/lang-help.R"
  lang <- "fr"
  dir <- fs::path("man-lang", lang)
  
  if(is_file(path)) {
    parsed <- roxygen2::parse_file(path)  
    for(roxy in parsed) {
      for(tag in roxy$tags) {
        translation <- llm_vec_translate(tag$raw, language = lang)
        print(glue("#' @{tag$tag} {translation}"))
      }
    }
  }
}
