to_title <- function(x) {
  split_x <- strsplit(x, " ")[[1]]
  split_title <- lapply(
    split_x,
    function(x){
      up <- toupper(x)
      lo <- tolower(x)
      paste0(substr(up, 1, 1), substr(lo, 2, nchar(lo)))
    }
    )
  paste0(as.character(split_title), collapse = " ")
}