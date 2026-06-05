#' Translates help documentation to another language
#' @description
#' Translates a given topic into a target language. It uses the `lang` argument
#' to determine which language to translate to. If not passed, this function will
#' look for a target language in the LANG and LANGUAGE environment variables, or
#' if something has been passed to the `.lang` argument in `lang_use()`, to
#' determine the target language. If the target language is English, no translation
#' will be processed, so the help returned will be the original package's
#' documentation.
#'
#' @param topic A character string specifying the help topic to translate.
#' @param package The R package to look for the topic, if not provided the
#' function will attempt to find the topic based on the loaded packages.
#' @param lang A character vector language to translate the topic to
#' @param context_size Maximum number of words for the context summary included
#' with each translation request. Set to `0` to disable context-aware
#' translation. When `NULL`, the value set via `lang_use()` is used (default
#' `100`).
#' @param type Produce "html" or "text" output for the help. It defaults to
#' `getOption("help_type")`
#' @returns Original or translated version of the help documentation in the
#' output type specified
#' @examples
#' \dontrun{
#' # Requires an interactive session with Ollama running locally
#' library(lang)
#'
#' lang_use("ollama", "llama3.2", seed = 100)
#'
#' lang_help("lang_help", lang = "spanish", type = "text")
#' }
#'
#' @export
lang_help <- function(
  topic,
  package = NULL,
  lang = NULL,
  context_size = NULL,
  type = getOption("help_type")
) {
  lang <- which_lang(lang, choose = TRUE)
  if (en_lang(lang)) {
    abort("Language already set to English, use `help()`")
  }
  rd <- rd_find(topic, package)
  context_size <- context_size %||% .lang_env$session[["context_size"]]
  topic_path <- rd_translate(rd$content, lang, context_size = context_size)
  topic <- rd$topic
  package <- rd$package
  structure(
    list(
      topic = topic,
      pkg = package,
      path = topic_path,
      stage = "render",
      type = type
    ),
    class = "lang_topic"
  )
}

rd_find <- function(topic, package = NULL) {
  if (is.null(package)) {
    # Gets the path to installed help file
    help_path <- as.character(utils::help(topic, help_type = "text"))
    if (length(help_path) == 0) {
      cli_abort(c(
        "Could not find {.field `{topic}`}",
        "i" = paste(
          "{.emph Tip: Make sure the containing package is loaded,",
          "and the topic is spelled correctly}"
        )
      ))
    }
    # Tracks back two levels to figure out package name: .../[pkg]/help/[topic]
    help_pkg <- path_dir(path_dir(help_path))
    # Extracts name of package by using the name of its source folder
    package <- path_file(help_pkg)
    # Ensures the correct topic file is pulled (geom_col is inside geom_bar)
    topic <- path_file(help_path)
  } else {
    pkg_exists <- find.package(package, quiet = TRUE)
    if (length(pkg_exists) == 0) {
      cli_abort(c(
        "Package {.pkg `{package}`} not found",
        "i" = "{.emph Tip: Make sure package name is spelled correctly}"
      ))
    }
  }
  db <- .lang_env$rd_db_cache[[package]] %||%
    {
      .lang_env$rd_db_cache[[package]] <- Rd_db(package)
    }
  content <- db[[path(topic, ext = "Rd")]]
  # If topic cannot be found, it will try and see if the topic is aliased
  # (geom_col is inside geom_bar)
  if (is.null(content)) {
    # Uses help() to find the actual name of the Rd file that contains
    # the function
    help_path <- as.character(utils::help(
      topic = topic,
      package = eval(package),
      help_type = "text"
    ))
    if (length(help_path) == 0) {
      cli_abort(c(
        "{.field `{topic}`} could not be found in {.pkg `{package}`}",
        "i" = "{.emph Tip: Make sure both are spelled correctly}"
      ))
    }
    # Updates the topic name
    topic <- path_file(help_path)
    content <- db[[path(topic, ext = "Rd")]]
  }
  list(topic = topic, package = package, content = content)
}

#' @export
print.lang_topic <- function(x, ...) {
  type <- arg_match0(x$type %||% "text", c("text", "html"))
  if (type == "html") {
    if (is_installed("rstudioapi") && isAvailable()) {
      return(callFun("previewRd", x$path))
    } else {
      html_file <- file_temp(ext = "html")
      writeLines(capture.output(Rd2HTML(x$path)), html_file)
      browseURL(html_file)
    }
  }
  if (type == "text") {
    Rd2txt(x$path)
  }
}
