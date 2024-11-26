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

split_lines <- function(x, size = 55, start_length = 0) {
  out <- NULL
  ln <- NULL
  ln_length <- start_length
  split_x <- unlist(strsplit(x, " "))
  for(word in split_x) {
    word_length <- nchar(word) 
    ln_length <- ln_length + word_length
    if(ln_length < size) {
      ln <- paste(ln, word)
    } else {
      out <- c(out, trimws(ln))
      ln <- word
      ln_length <- 0
    }
  }
  if(ln_length != 0) {
    out <- c(out, trimws(ln))
  }
  out  
}

split_paragraphs <- function(x, size = 55) {
  x_lines <- trimws(unlist(strsplit(x, "\n")))
  out <- NULL
  for(x_line in x_lines) {
    if(x_line != "") {
      x_prep <- split_lines(x_line, size)
    } else {
      x_prep <- ""
    }
    out <- c(out, x_prep)
  }
  out  
}
