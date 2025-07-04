to_title <- function(x) {
  split_x <- strsplit(x, " ")[[1]]
  split_title <- lapply(
    split_x,
    function(x) {
      up <- toupper(x)
      lo <- tolower(x)
      paste0(substr(up, 1, 1), substr(lo, 2, nchar(lo)))
    }
  )
  paste0(as.character(split_title), collapse = " ")
}

tag_to_label <- function(x) {
  x <- gsub("\\\\", "", x)
  tag_labels <- c(
    "title" = "Title",
    "description" = "Description",
    "value" = "Value",
    "details" = "Details",
    "seealso" = "See Also",
    "examples" = "Examples",
    "arguments" = "Arguments",
    "usage" = "Usage",
    "output" = "Output",
    "returns" = "Returns",
    "return" = "Return"
  )
  match <- tag_labels[names(tag_labels) == x]
  if (length(match) > 0) {
    x <- as.character(match)
  }
  x
}
