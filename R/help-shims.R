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
shim_lang_help <- function(topic, package = NULL, ...) {
  topic_name <- substitute(topic)
  is_string <- tryCatch(
    error = function(...) FALSE,
    {
      force(topic)
      is_string(topic)
    }
  )
  
  topic_str <- NULL
  if (is_string) {
    topic_str <- topic
    topic_name <- sym(topic)
  } else if (missing(topic_name)) {
    # Leave the vars missing
  } else if (is_null(topic_name)) {
    topic_str <- deparse(topic_name)
    topic_name <- NULL
  } else {
    topic_str <- deparse(substitute(topic))
    if (length(topic_str) != 1) {
      cli::cli_abort("{.arg topic} must be a name.")
    }
  }

  package_name <- substitute(package)
  if (is_symbol(package_name)) {
    package_str <- as_string(package_name)
  } else {
    package_str <- package
    package_name <- package
  }

  if (!en_lang()) {
    lang_help(topic_str, package_str, ...)
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
shim_lang_question <- function(e1, e2) {
  e1_expr <- substitute(e1)
  # ??foo -- Will not translate
  # Using `ifelse` because if its not a call, then `e1_expr` cannot be subset
  is_vague <- ifelse(is_call(e1_expr), identical(e1_expr[[1]], quote(`?`)) , FALSE) 
  if(en_lang() | is_vague) {
    # Passing as-is if language is English, or there is a `??` call
    eval(as.call(list(utils::`?`, substitute(e1), substitute(e2))))
  } else {
    pkg <- NULL
    if (is.name(e1_expr)) {
      # ?foo
      topic <- as.character(e1_expr)
    } else if (is.call(e1_expr)) {
      if (identical(e1_expr[[1]], quote(`::`))) {
        # ?bar::foo
        topic <- as.character(e1_expr[[3]])
        pkg <- as.character(e1_expr[[2]])
      } else {
        # ?foo(12)
        topic <- deparse(e1_expr[[1]])
      }
    } else if (is.character(e1_expr)) {
      # ?"foo"
      topic <- e1
    } else if(is.null(e1) && is_missing(e2)) {
      topic <- deparse(e1)
    }else {
      cli_abort("Unknown input.")
    }
    lang_help(topic, pkg)
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
  e$help <- shim_lang_help
  e$`?` <- shim_lang_question
  base::attach(
    what = e,
    name = "lang_shims",
    warn.conflicts = FALSE
  )
}

which_lang <- function(lang = NULL, choose = FALSE) {
  if (is.null(lang)) {
    session_lang <- .lang_env$session[[".lang"]]
    if (!is.null(session_lang)) {
      return(session_lang)
    }
    env_lang <- Sys.getenv("LANG", unset = NA)
    env_language <- Sys.getenv("LANGUAGE", unset = NA)
    lang <- c(LANG = env_lang, LANGUAGE = env_language)
    lang <- lang[!is.na(lang)]
    lang <- lang[lang != "C"]
    lang <- lang[!startsWith(lang, "C.")]
    if (length(lang) > 1 && choose) {
      if (unique(length(lang) > 1) && is.null(.lang_env$choose)) {
        cli_bullets(
          c(
            "i" =  "The `LANG` and `LANGUAGE` variables have different values.\n",
            " " = "Will use value of `LANGUAGE`: {.val {env_language}}",
            " " = "{.emph This message will only appear once during your session}"
          )
        )
        .lang_env$choose <- TRUE
      }
      lang <- env_language
    }
    if (length(lang) == 0) {
      lang <- "english"
    }
  }
  if (length(lang) == 1 && choose) {
    .lang_env$session[[".lang"]] <- lang
  }
  lang
}

en_lang <- function(lang = NULL) {
  is_en <- NULL
  langs <- which_lang(lang)
  for (lang in langs) {
    if (nchar(lang) > 2) {
      curr_en <- substr(lang, 1, 3) == "en_" | lang == tolower("english")
      is_en <- c(is_en, curr_en)
    }
  }
  all(is_en)
}
