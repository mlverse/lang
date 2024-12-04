#'  Funciones para integrar diferentes back-end.
#' @param backend  Sesión de tienda de fondo
#' @param x  El cuerpo del texto a someter a la LLM.
#' @param prompt  Información adicional para agregar en la solicitud de
#' subvención.
#' @param additional  Texto adicional para agregar al promotor base
#' @param preview  si `VERDADERO`, mostrará la llamada R resultante de la
#' primera text en `x`.
#' @returns No devuelve un objeto. `m_backend_prompt` devuelve una lista de
#' funciones que contienen los promedios básicos.
#' @keywords internal
#' @export
m_backend_submit <- function(backend, x, prompt, preview = FALSE) {
  UseMethod("m_backend_submit")
}
#' @export
m_backend_submit.mall_ollama <- function(backend, x, prompt, preview = FALSE) {
  if (preview) {
    x <- head(x, 1)
    map_here <- map
  } else {
    map_here <- map_chr
  }
  map_here(x, function(x) {
    .args <- c(messages = list(map(prompt, function(i) map(i, function(j) glue(j, x = x)))), output = "text", m_defaults_args(backend))
    res <- NULL
    if (preview) {
      res <- expr(ollamar::chat(!!!.args))
    }
    if (m_cache_use() && is.null(res)) {
      hash_args <- hash(.args)
      res <- m_cache_check(hash_args)
    }
    if (is.null(res)) {
      res <- exec("chat", !!!.args)
      m_cache_record(.args, res, hash_args)
    }
    res
  })
}
#' @export
m_backend_submit.mall_elmer <- function(backend, x, prompt, preview = FALSE) {
  if (preview) {
    x <- head(x, 1)
    map_here <- map
  } else {
    map_here <- map_chr
  }
  map_here(x, function(x) {
    .args <- c(glue(prompt[[1]]$content, x = x))
    res <- NULL
    if (preview) {
      res <- expr(x$chat(!!!.args))
    }
    if (m_cache_use() && is.null(res)) {
      hash_args <- hash(.args)
      res <- m_cache_check(hash_args)
    }
    if (is.null(res)) {
      args <- m_defaults_args()
      arg_chat <- args$elmer_obj$chat
      res <- exec("arg_chat", !!!.args)
      m_cache_record(.args, res, hash_args)
    }
    res
  })
}
#' @export
m_backend_submit.mall_simulate_llm <- function(backend, x, prompt, preview = FALSE) {
  .args <- as.list(environment())
  args <- m_defaults_args(backend)
  if (args$model == "pipe") {
    out <- map_chr(x, function(x) trimws(strsplit(x, "\\|")[[1]][[2]]))
  } else if (args$model == "echo") {
    out <- x
  } else if (args$model == "prompt") {
    out <- prompt
  }
  res <- NULL
  if (m_cache_use()) {
    hash_args <- hash(.args)
    res <- m_cache_check(hash_args)
  }
  if (is.null(res)) {
    .args$backend <- NULL
    m_cache_record(.args, out, hash_args)
  }
  out
}
