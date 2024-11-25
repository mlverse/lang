.onLoad <- function(libname, pkgname) {
  insert_global_shims(force = TRUE)
}


#' Drop-in replacements for help and ? functions
#'
#' The `?` and `help` functions are replacements for functions of the
#' same name in the utils package. If the LANG environment variable is not set
#' to English, it will activate the translation to whatever language LANG is
#' set to.
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
  } else if ("pkgload" %in% loadedNamespaces()) {
    exec(getExportedValue("pkgload", "dev_help"), topic_name, package_name)
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
  } else if ("pkgload" %in% loadedNamespaces()) {
    exec(getExportedValue("pkgload", "dev_help"), topic, pkg)
  } else {
    eval(as.call(list(utils::`?`, substitute(e1), substitute(e2))))
  }
}

insert_global_shims <- function(force = FALSE) {
  if ("lang_shims" %in% search()) {
    if (!force) {
      # If shims already present, just return
      return()
    }
    base::detach("lang_shims")
  }
  e <- new.env()
  e$help <- shim_help
  e$`?` <- shim_question
  base::attach(
    what = e,
    name = "lang_shims",
    warn.conflicts = FALSE
  )
}

which_lang <- function(lang = NULL) {
  if (is.null(lang)) {
    env_lang <- Sys.getenv("LANG", unset = NA)
    env_language <- Sys.getenv("LANGUAGE", unset = NA)
    lang <- "english"
    if (!is.na(env_lang)) {
      lang <- env_lang
    }
    if (!is.na(env_language)) {
      lang <- env_language
    }
  }
  lang
}

en_lang <- function(lang = NULL) {
  out <- FALSE
  lang <- which_lang(lang)
  if (nchar(lang) > 2) {
    if (substr(lang, 1, 3) == "en_" | lang == tolower("english")) {
      out <- TRUE
    }
  }
  out
}
