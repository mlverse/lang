#' @importFrom withr local_tempdir with_dir
#' @importFrom utils capture.output object.size
#' @import tools
#' @import rlang
#' @import glue
#' @import mall
#' @import cli
#' @import fs
.lang_env <- new.env()
.lang_env$session <- list()
.lang_env$choose <- NULL
