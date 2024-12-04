#' ¿Verifica si una afirmación sobre el texto es cierta o no?
#' @description Utiliza un modelo de lenguaje grande (LLM) para ver si algo es
#' cierto o no.
#' @inheritParams llm_classify
#' @param what  ¿Qué afirmación o pregunta que se debe verificar en contra del
#' texto proporcionado?
#' @param yes_no  Un tamaño 2 vector que especifica la salida esperada. Es
#' posicional. El primer elemento es el valor a devolver si el estado de la frase
#' proporcionada es cierto y el segundo si no lo es. Por defecto es:
#' `factor(c(1, 0))`.
#' @returns Verifica si la función llm_verify devuelve un data.frame o una
#' tabla. La función llm_vec_verify devuelve un vector con el mismo tamaño que
#' x.
#' @examples
#' \donttest{
#' library(mall)
#'
#' data("reviews")
#'
#' llm_use("ollama", "llama3.2", seed = 100, .silent = TRUE)
#'
#' # By default it will return 1 for 'true', and 0 for 'false',
#' # the new column will be a factor type
#' llm_verify(reviews, review, "is the customer happy")
#'
#' # The yes_no argument can be modified to return a different response
#' # than 1 or 0. First position will be 'true' and second, 'false'
#' llm_verify(reviews, review, "is the customer happy", c("y", "n"))
#'
#' # Number can also be used, this would be in the case that you wish to match
#' # the output values of existing predictions
#' llm_verify(reviews, review, "is the customer happy", c(2, 1))
#' }
#'
#' @export
llm_verify <- function(.data, col, what, yes_no = factor(c(1, 0)), pred_name = ".verify", additional_prompt = "") {
  UseMethod("llm_verify")
}
#' @export
llm_verify.data.frame <- function(.data, col, what, yes_no = factor(c(1, 0)), pred_name = ".verify", additional_prompt = "") {
  mutate(.data = .data, `:=`(!!pred_name, llm_vec_verify(x = {{ col }}, what = what, yes_no = yes_no, additional_prompt = additional_prompt)))
}
#' @rdname llm_verify
#' @export
llm_vec_verify <- function(x, what, yes_no = factor(c(1, 0)), additional_prompt = "", preview = FALSE) {
  m_vec_prompt(x = x, prompt_label = "verify", what = what, labels = yes_no, valid_resps = yes_no, convert = c(yes = yes_no[1], no = yes_no[2]), additional_prompt = additional_prompt, preview = preview)
}
