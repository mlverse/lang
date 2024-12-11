roxy_comments <- function(x) {
  script_contents <- readLines(x)
  roxy_comment <- substr(script_contents, 1, 2) == "#'"
  just_roxy <- script_contents[roxy_comment]
  just_roxy <- just_roxy[just_roxy != "#'"]
  
  if (length(just_roxy) == 0) {
    return(NULL)
  } else {
    just_roxy <- paste0("#-", just_roxy)
    no_exports <- !any(grepl("#' @export", just_roxy))
    no_name <- !any(grepl("#' @name", just_roxy))
    if (no_exports && no_name) {
      return(NULL)
    }
  }
  just_roxy
}

roxy_existing <- function(x) {
  script_contents <- readLines(x)
  roxy_comment <- substr(script_contents, 1, 4) == "#-#'"
  script_contents[roxy_comment]
}
