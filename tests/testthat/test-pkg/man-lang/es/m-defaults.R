#' @export
print.mall_session <- function(x, ...) {
  cli_h3("{col_cyan('mall')} session object")
  args <- x[["args"]]
  args[["elmer_obj"]] <- NULL
  cli_inform(glue("{col_green('Backend:')} {x$name}"))
  args <- imap(args, function(x, y) glue("{col_yellow({paste0(y, ':')})}{x}"))
  label_argument <- "{col_green('LLM session:')}"
  if (length(args) == 1) {
    cli_inform(paste(label_argument, args[[1]]))
  } else {
    cli_inform(label_argument)
    args <- as.character(args)
    args <- set_names(args, " ")
    cli_bullets(args)
  }
  session <- x$session
  if (session$cache_folder == "") {
    session$cache_folder <- NULL
  }
  if (length(session) > 0) {
    session <- imap(session, function(x, y) glue("{col_yellow({paste0(y, ':')})}{x}"))
    label_argument <- "{col_green('R session:')}"
    cli_inform(paste(label_argument, session[[1]]))
  }
}
