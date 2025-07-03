.lang_env <- new.env()
.lang_env$session <- list()

#' Specify the model to use
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
#' @returns Console output of the current LLM setup to be used during the
#' R session.
#'
#' @export
lang_use <- function(
    backend = NULL,
    model = NULL,
    .cache = NULL,
    ...) {
  lang_use_impl(
    backend = backend,
    model = model,
    .cache = .cache,
    .is_internal = FALSE,
    ... = ...
  )
}

lang_use_impl <- function(
    backend = NULL,
    model = NULL,
    .cache = NULL,
    .is_internal = FALSE,
    ...) {
  args <- list(...)
  ca <- .lang_env$session
  ca[["backend"]] <- backend %||% ca[["backend"]] %||% getOption(".lang_chat")
  ca[["model"]] <- model %||% ca[["model"]]
  ca[[".cache"]] <- .cache %||% ca[[".cache"]] %||% tempfile("_lang_cache")
  if (length(args) > 0) {
    ca[["args"]] <- args
  }
  .lang_env$session <- ca
  if (.is_internal) {
    return(ca)
  } else {
    print(ca)
  }
  invisible()
}
