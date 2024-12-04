#' Traduce el texto a una lengua específica.
#' @description Utiliza un modelo de lenguaje grande (MLL) para traducir un
#' texto a una lengua específica.
#' @inheritParams llm_classify
#' @param language  Spanish
#' @examples
#' \donttest{
#' library(mall)
#'
#' data("reviews")
#'
#' llm_use("ollama", "llama3.2", seed = 100, .silent = TRUE)
#'
#' # Pass the desired language to translate to
#' llm_translate(reviews, review, "spanish")
#' }
#' @returns `llm_translate` devuelve un objeto de tipo `data.frame` o `tbl`.
#' `llm_vec_translate` devuelve una matriz que tiene el mismo tamaño que `x`.
#' @export
llm_translate <- function(.data, col, language, pred_name = ".translation", additional_prompt = "") {
  UseMethod("llm_translate")
}
#' @export
llm_translate.data.frame <- function(.data, col, language, pred_name = ".translation", additional_prompt = "") {
  mutate(.data = .data, `:=`(!!pred_name, llm_vec_translate(x = {{ col }}, language = language, additional_prompt = additional_prompt)))
}
#' @rdname llm_translate
#' @export
llm_vec_translate <- function(x, language, additional_prompt = "", preview = FALSE) {
  m_vec_prompt(x = x, prompt_label = "translate", additional_prompt = additional_prompt, language = language, preview = preview)
}
