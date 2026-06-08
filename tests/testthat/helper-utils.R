rd_test_translate <- function(rd_path, lang = "spanish") {
  rd_content <- if (grepl("\\.rds$", rd_path)) {
    readRDS(rd_path)
  } else {
    tools::parse_Rd(rd_path)
  }
  tmp <- rd_translate(rd_content, lang, context_size = 100L)
  tools::Rd2txt(tmp)
}

simulate_ellmer <- function() {
  setClass(
    Class = "simulate_provider",
    slots = c(name = "character", model = "character"),
    contains = "list"
  )

  ellmer_object <- list(
    get_provider = function() {
      x <- as(list(), "simulate_provider")
      x@name <- "test_name"
      x@model <- "test_model"
      x
    }
  )
  class(ellmer_object) <- "Chat"
  ellmer_object
}
