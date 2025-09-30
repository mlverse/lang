#' Specifies the LLM provider and model to use during the R session
#' @description
#' Allows us to specify the back-end provider, model to use during the current
#' R session.
#' @param backend "ollama" or an `ellmer` `Chat` object. If using "ollama",
#' `mall` will use is out-of-the-box integration with that back-end. Defaults
#' to "ollama".
#' @param model The name of model supported by the back-end provider
#' @param ... Additional arguments that this function will pass down to the
#' integrating function. In the case of Ollama, it will pass those arguments to
#' `ollamar::chat()`.
#' @param .cache The path to save model results, so they can be re-used if
#' the same operation is ran again. To turn off, set this argument to an empty
#' character: `""`. It defaults to a temp folder. If this argument is left
#' `NULL` when calling this function, no changes to the path will be made.
#' @param .lang Target language to translate to. This will override values found
#' in the LANG and LANGUAGE environment variables.
#' @param .silent Boolean flag that controls if there is or not output to the
#' console. Defaults to FALSE.
#' @returns Console output of the current LLM setup to be used during the
#' R session.
#'
#' @examples
#' \donttest{
#' library(lang)
#'
#' # Using an `ellmer` chat object
#' lang_use(ellmer::chat_openai(model = "gpt-4o"))
#'
#' # Using Ollama directly
#' lang_use("ollama", "llama3.2", seed = 100)
#'
#' # Turn off cache by setting `.cache` to ""
#' lang_use("ollama", "llama3.2", seed = 100, .cache = "")
#'
#' # Use `.lang` to set the target language to translate to,
#' # it will be set for the current R session
#' lang_use("ollama", "llama3.2", .lang = "spanish")
#'
#' # Use `.silent` to avoid console output
#' lang_use("ollama", "llama3.2", .lang = "spanish", .silent = TRUE)
#'
#' # To see current settings, simply call the function
#' lang_use()
#' }
#'
#' @export
lang_use <- function(
    backend = NULL,
    model = NULL,
    .cache = NULL,
    .lang = NULL,
    .silent = FALSE,
    ...) {
  lang_use_impl(
    backend = backend,
    model = model,
    .cache = .cache,
    .is_internal = FALSE,
    .lang = .lang,
    .silent = .silent,
    ... = ...
  )
}

lang_use_impl <- function(
    backend = NULL,
    model = NULL,
    .cache = NULL,
    .is_internal = FALSE,
    .lang = NULL,
    .silent = FALSE,
    ...) {
  args <- list(...)
  ca <- .lang_env$session
  if (!is.null(getOption(".lang_chat"))) {
    cli_warn(c(
      "Option `.lang_chat` is no longer supported",
      "Use `lang::lang_use([backend])` in your .RProfile file instead"
    ))
  }
  ca[["backend"]] <- backend %||% ca[["backend"]]
  ca[["model"]] <- model %||% ca[["model"]]
  temp_lang <- tempfile("_lang_cache")
  ca[[".cache"]] <- .cache %||% ca[[".cache"]] %||% temp_lang
  ca[[".lang"]] <- .lang %||% ca[[".lang"]]
  if (length(args) > 0) {
    ca[["args"]] <- args
  }
  .lang_env$session <- ca
  if (.is_internal) {
    return(ca)
  } else if (!.silent) {
    backend <- ca[["backend"]]
    if (inherits(backend, "Chat")) {
      provider <- backend$get_provider()
      backend_str <- glue("'{provider@name}' via `ellmer`")
      model_str <- provider@model
    } else if (is.null(backend)) {
      backend_str <- "[Unset]"
      model_str <- ca[["model"]]
    } else {
      backend_str <- "Ollama"
      model_str <- ca[["model"]]
    }
    if (ca[[".cache"]] == "") {
      cache_str <- "[Disabled]"
    } else {
      cache_str <- ca[[".cache"]]
    }
    current_lang <- which_lang(.lang, choose = TRUE)
    cli_inform("{symbol$em_dash} {col_cyan('`lang`')} session")
    cli_inform(glue("{col_green('Backend:')} {backend_str}"))
    if (!is.null(model_str)) {
      cli_inform(glue("{col_green('Model:')} {model_str}"))
    }
    if (path_dir(ca[[".cache"]]) != path_dir(temp_lang)) {
      cli_inform(glue("{col_green('Cache:')} {cache_str}"))
    }
    cli_inform(glue("{col_green('Language:')} {current_lang}"))
  }
  invisible()
}
