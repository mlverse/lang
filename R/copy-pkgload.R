.onLoad <- function(libname, pkgname) {
  insert_global_shims(force = TRUE)
}


#' Drop-in replacements for help and ? functions
#'
#' The `?` and `help` functions are replacements for functions of the
#' same name in the utils package. 
#' 
#' The `?` function is a replacement for [utils::?()] from the
#' utils package. It will search for help in devtools-loaded packages first,
#' then in regular packages.
#'
#' The `help` function is a replacement for [utils::help()] from
#' the utils package. If `package` is not specified, it will search for
#' help in devtools-loaded packages first, then in regular packages. If
#' `package` is specified, then it will search for help in devtools-loaded
#' packages or regular packages, as appropriate.
#'
#' @param topic A name or character string specifying the help topic.
#' @param package A name or character string specifying the package in which
#'   to search for the help topic. If NULL, search all packages.
#' @param e1 First argument to pass along to `utils::`?``.
#' @param e2 Second argument to pass along to `utils::`?``.
#' @param ... Additional arguments to pass to [utils::help()].
#'
#' @rdname help
#' @name help
#' @usage # help(topic, package = NULL, ...)
#'
#' @examples
#' \dontrun{
#' # This would load devtools and look at the help for load_all, if currently
#' # in the devtools source directory.
#' load_all()
#' ?load_all
#' help("load_all")
#' }
#'
#' # To see the help pages for utils::help and utils::`?`:
#' help("help", "utils")
#' help("?", "utils")
#'
#' \dontrun{
#' # Examples demonstrating the multiple ways of supplying arguments
#' # NB: you can't do pkg <- "ggplot2"; help("ggplot2", pkg)
#' help(lm)
#' help(lm, stats)
#' help(lm, 'stats')
#' help('lm')
#' help('lm', stats)
#' help('lm', 'stats')
#' help(package = stats)
#' help(package = 'stats')
#' topic <- "lm"
#' help(topic)
#' help(topic, stats)
#' help(topic, 'stats')
#' }
shim_help <- function(topic, package = NULL, ...) {
  # Reproduce help's NSE for topic - try to eval it and see if it's a string
  topic_name <- substitute(topic)
  
  is_string <- tryCatch(
    error = function(...) FALSE,
    {
      force(topic)
      is_string(topic)
    }
  )
  
  if (is_string) {
    topic_str <- topic
    topic_name <- sym(topic)
  } else if (missing(topic_name)) {
    # Leave the vars missing
  } else if (is_null(topic_name)) {
    topic_str <- NULL
    topic_name <- NULL
  } else {
    topic_str <- deparse(substitute(topic))
    if (length(topic_str) != 1) {
      cli::cli_abort("{.arg topic} must be a name.")
    }
  }
  
  # help's NSE for package is slightly simpler
  package_name <- substitute(package)
  if (is_symbol(package_name)) {
    package_str <- as_string(package_name)
  } else {
    # Complex expression, just evaluate it (#266). The value is
    # injected in `utils::help(package = )` below, causing it to be
    # interpreted as is.
    package_str <- package
    package_name <- package
  }
  
  if (!en_lang()) {
    lang_help(topic_str, package_str)
  } else {
    inject(utils::help(
      !!maybe_missing(topic_name),
      !!maybe_missing(package_name),
      ...
    ))
  }
  
  
}


#' @usage
#' # ?e2
#' # e1?e2
#'
#' @rdname help
#' @name ?
shim_question <- function(e1, e2) {
  pkg <- NULL
  # Get string version of e1, for find_topic
  e1_expr <- substitute(e1)
  if (is.name(e1_expr)) {
    # Called with a bare symbol, like ?foo
    topic <- as.character(e1_expr)
    pkg <- NULL
  } else if (is.call(e1_expr)) {
    if (identical(e1_expr[[1]], quote(`?`))) {
      # ??foo
      topic <- NULL
      pkg <- NULL
    } else if (identical(e1_expr[[1]], quote(`::`))) {
      # ?bar::foo
      topic <- as.character(e1_expr[[3]])
      pkg <- as.character(e1_expr[[2]])
    } else {
      # ?foo(12)
      topic <- deparse(e1_expr[[1]])
      pkg <- NULL
    }
  } else if (is.character(e1_expr)) {
    topic <- e1
    pkg <- NULL
  } else {
    cli::cli_abort("Unknown input.")
  }
  
  if (!en_lang()) {
    lang_help(topic, pkg)
  } else {
    eval(as.call(list(utils::`?`, substitute(e1), substitute(e2))))
  }
 
}

insert_global_shims <- function(force = FALSE) {
  if ("devtools_shims" %in% search()) {
    if (!force) {
      # If shims already present, just return
      return()
    }
    base::detach("devtools_shims")
  }
  
  e <- new.env()
  
  e$help <- shim_help
  e$`?` <- shim_question
  #e$system.file <- shim_system.file
  
  base::attach(e, name = "devtools_shims", warn.conflicts = FALSE)
}

en_lang <- function(lang = NULL) {
  out <- FALSE
  if(is.null(lang)) {
    lang <- Sys.getenv("LANG", unset = "")  
  }
  if(nchar(lang) > 2) {
    if(substr(lang, 1, 3) == "en_" | lang == tolower("english")) {
      out <- TRUE
    } 
  }
  out
}