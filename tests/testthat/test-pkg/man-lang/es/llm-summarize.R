#' No texto proporcionado por favor
#' @description Utiliza un modelo de Lenguaje Grande (LLM) para resumir
#' texto.
#' @inheritParams llm_classify
#' @param max_words  El número máximo de palabras que la LLM debe utilizar en la
#' resumenada. Por defecto es de 10.
#' @examples
#' \donttest{
#' library(mall)
#'
#' data("reviews")
#'
#' llm_use("ollama", "llama3.2", seed = 100, .silent = TRUE)
#'
#' # Use max_words to set the maximum number of words to use for the summary
#' llm_summarize(reviews, review, max_words = 5)
#'
#' # Use 'pred_name' to customize the new column's name
#' llm_summarize(reviews, review, 5, pred_name = "review_summary")
#'
#' # For character vectors, instead of a data frame, use this function
#' llm_vec_summarize(
#'   "This has been the best TV I've ever used. Great screen, and sound.",
#'   max_words = 5
#' )
#'
#' # To preview the first call that will be made to the downstream R function
#' llm_vec_summarize(
#'   "This has been the best TV I've ever used. Great screen, and sound.",
#'   max_words = 5,
#'   preview = TRUE
#' )
#' }
#' @returns "llm_summarize" devuelve un objeto de tipo data.frame o tbl.
#' "llm_vec_summarize" devuelve una lista vectorial que tiene el mismo
#' tamaño que "x".
#' @export
llm_summarize <- function(.data, col, max_words = 10, pred_name = ".summary", additional_prompt = "") {
  UseMethod("llm_summarize")
}
#' @export
llm_summarize.data.frame <- function(.data, col, max_words = 10, pred_name = ".summary", additional_prompt = "") {
  mutate(.data = .data, `:=`(!!pred_name, llm_vec_summarize(x = {{ col }}, max_words = max_words, additional_prompt = additional_prompt)))
}
#' @export
`llm_summarize.tbl_Spark SQL` <- function(.data, col, max_words = 10, pred_name = ".summary", additional_prompt = NULL) {
  mutate(.data = .data, `:=`(!!pred_name, ai_summarize({{ col }}, as.integer(max_words))))
}
#' @rdname llm_summarize
#' @export
llm_vec_summarize <- function(x, max_words = 10, additional_prompt = "", preview = FALSE) {
  m_vec_prompt(x = x, prompt_label = "summarize", additional_prompt = additional_prompt, max_words = max_words, preview = preview)
}
