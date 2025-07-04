.lang_env <- new.env()
.lang_env$session <- list()

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
#' @returns Console output of the current LLM setup to be used during the
#' R session.
#'
#' @examples
#' \donttest{ 
#'   library(lang)
#'   
#'   # Using an `ellmer` chat object
#'   lang_use(ellmer::chat_openai(model = "gpt-4o"))
#'   
#'   # Using Ollama directly
#'   lang_use("ollama", "llama3.2", seed = 100)
#'   
#'   # Turn off cache by setting it to ""
#'   lang_use("ollama", "llama3.2", seed = 100, .cache = "")
#' }
#' 
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
    backend <- ca[["backend"]]
    if (inherits(backend, "Chat")) { 
      provider <- backend$get_provider()
      backend_str <- glue("'{provider@name}' via `ellmer`")
      model_str <- provider@model
    } else {
      backend_str <- "Ollama"
      model_str <- ca[["model"]] 
    }
    if(ca[[".cache"]] == "") {
      cache_str <- "[Disabled]"
    } else {
      cache_str <- ca[[".cache"]]
    }
    cli_h3("{col_cyan('`lang`')} session")
    cli_inform(glue("{col_green('Backend:')} {backend_str}"))
    cli_inform(glue("{col_green('Model:')} {model_str}"))
    cli_inform(glue("{col_green('Cache:')} {cache_str}"))  
  }
  invisible()
}
