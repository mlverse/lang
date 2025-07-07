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
