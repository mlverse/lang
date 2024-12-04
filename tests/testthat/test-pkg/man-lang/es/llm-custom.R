#' Envíe un enlace personalizado al modelo de lenguaje grande
#' @description Utiliza un modelo de lenguaje grande (LLM) para procesar el
#' texto proporcionado según las instrucciones del `prompt`.
#' @inheritParams llm_classify
#' @param prompt  "Añadir el siguiente texto como comentarios a cada registro
#' enviado al modelo de inteligencia artificial"
#' @param valid_resps  No respuesta disponible.
#' @examples
#' \donttest{
#' library(mall)
#'
#' data("reviews")
#'
#' llm_use("ollama", "llama3.2", seed = 100, .silent = TRUE)
#'
#' my_prompt <- paste(
#'   "Answer a question.",
#'   "Return only the answer, no explanation",
#'   "Acceptable answers are 'yes', 'no'",
#'   "Answer this about the following text, is this a happy customer?:"
#' )
#'
#' reviews |>
#'   llm_custom(review, my_prompt)
#' }
#' @returns `llm_custom` devuelve un data.frame o tbl objeto.
#' `llm_vec_custom` devuelve un vector de la misma longitud que `x`.
#' @export
llm_custom <- function(.data, col, prompt = "", pred_name = ".pred", valid_resps = "") {
  UseMethod("llm_custom")
}
#' @export
llm_custom.data.frame <- function(.data, col, prompt = "", pred_name = ".pred", valid_resps = NULL) {
  mutate(.data = .data, `:=`(!!pred_name, llm_vec_custom(x = {{ col }}, prompt = prompt, valid_resps = valid_resps)))
}
#' @rdname llm_custom
#' @export
llm_vec_custom <- function(x, prompt = "", valid_resps = NULL) {
  m_vec_prompt(x = x, prompt = prompt, valid_resps = valid_resps)
}
