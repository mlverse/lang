#' Categorizar los datos como una de las opciones dadas.
#' @description "Utiliza un modelo de lenguaje grande para clasificar el
#' texto proporcionado como uno de los opciones ofrecidas a través del
#' argumento `labels`."
#' @param .data  Datos de una tabla o data frame que contiene el texto a ser
#' analizado.
#' @param col  El nombre del campo para analizar, soporta 'tidy-eval'.
#' @param x  Veces de texto para ser analizado
#' @param additional_prompt  "Inserte este texto en el promedio que se envió a
#' la LLM."
#' @param pred_name  Nombre del nuevo colón donde se colocará la predicción
#' @param labels  Etiquetas un vector de caracteres con al menos 2 etiquetas
#' para clasificar el texto
#' @param preview  Devuelve el llamado R que habría sido utilizado para
#' ejecutar la predicción. Solo devuelve el primer registro de `x`. Por
#' defecto es `FALSO`. Aplica solo a funciones de vector.
#' @returns llm_classify devuelve un data.frame o tbl objeto, mientras que
#' llm_vec_classify devuelve un vector con el mismo largo que x.
#' @examples
#' \donttest{
#' library(mall)
#'
#' data("reviews")
#'
#' llm_use("ollama", "llama3.2", seed = 100, .silent = TRUE)
#'
#' llm_classify(reviews, review, c("appliance", "computer"))
#'
#' # Use 'pred_name' to customize the new column's name
#' llm_classify(
#'   reviews,
#'   review,
#'   c("appliance", "computer"),
#'   pred_name = "prod_type"
#' )
#'
#' # Pass custom values for each classification
#' llm_classify(reviews, review, c("appliance" ~ 1, "computer" ~ 2))
#'
#' # For character vectors, instead of a data frame, use this function
#' llm_vec_classify(
#'   c("this is important!", "just whenever"),
#'   c("urgent", "not urgent")
#' )
#'
#' # To preview the first call that will be made to the downstream R function
#' llm_vec_classify(
#'   c("this is important!", "just whenever"),
#'   c("urgent", "not urgent"),
#'   preview = TRUE
#' )
#' }
#' @export
llm_classify <- function(.data, col, labels, pred_name = ".classify", additional_prompt = "") {
  UseMethod("llm_classify")
}
#' @export
llm_classify.data.frame <- function(.data, col, labels, pred_name = ".classify", additional_prompt = "") {
  mutate(.data = .data, `:=`(!!pred_name, llm_vec_classify(x = {{ col }}, labels = labels, additional_prompt = additional_prompt)))
}
#' @export
`llm_classify.tbl_Spark SQL` <- function(.data, col, labels, pred_name = ".classify", additional_prompt = "") {
  prep_labels <- paste0("'", labels, "'", collapse = ", ")
  mutate(.data = .data, `:=`(!!pred_name, ai_classify({{ col }}, array(sql(prep_labels)))))
}
#' @rdname llm_classify
#' @export
llm_vec_classify <- function(x, labels, additional_prompt = "", preview = FALSE) {
  m_vec_prompt(x = x, prompt_label = "classify", additional_prompt = additional_prompt, labels = labels, valid_resps = labels, preview = preview)
}
