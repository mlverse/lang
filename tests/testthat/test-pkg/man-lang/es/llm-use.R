#' Especifique el modelo a utilizar.
#' @description Permite especificar el proveedor de back-end y el modelo a
#' utilizar durante la sesión R actual.
#' @param backend  El nombre de un proveedor de back-end soportado.
#' Actualmente solo se apoya en 'ollama'.
#' @param .silent  Evita la salida de consola.
#' @param model  Nombre de modelo admitido por el proveedor detrás
#' @param ...  Agregados que esta función pasará al integrador. En el caso de
#' Ollama, esos argumentos pasarán a `ollamar::chat()`.
#' @param .force  La bandera de fuerza que indica la función para restablecer
#' todos los parámetros en sesión de R.
#' @param .cache  La ruta de guardar los resultados del modelo, para que se
#' puedan reutilizar si se repite la misma operación. Para desactivar,
#' establecer esta variable en un carácter vacío: "" . Se defaults a una carpeta
#' temporal. Si esta variable es igual a NULL cuando llamar esta función, no se
#' harán cambios de ruta.
#' @examples
#' \donttest{
#' library(mall)
#'
#' llm_use("ollama", "llama3.2")
#'
#' # Additional arguments will be passed 'as-is' to the
#' # downstream R function in this example, to ollama::chat()
#' llm_use("ollama", "llama3.2", seed = 100, temperature = 0.1)
#'
#' # During the R session, you can change any argument
#' # individually and it will retain all of previous
#' # arguments used
#' llm_use(temperature = 0.3)
#'
#' # Use .cache to modify the target folder for caching
#' llm_use(.cache = "_my_cache")
#'
#' # Leave .cache empty to turn off this functionality
#' llm_use(.cache = "")
#'
#' # Use .silent to avoid the print out
#' llm_use(.silent = TRUE)
#' }
#' @returns Una sesión de tienda (mall_session)
#' @export
llm_use <- function(backend = NULL, model = NULL, ..., .silent = FALSE, .cache = NULL, .force = FALSE) {
  elmer_obj <- NULL
  models <- list()
  supplied <- sum(!is.null(backend), !is.null(model))
  not_init <- inherits(m_defaults_get(), "list")
  if (supplied == 2) {
    not_init <- FALSE
  }
  if (inherits(backend, "Chat")) {
    if (!is.null(model)) {
      cli_abort(c("Elmer objects already have the 'model' selected.", "Please try again leaving `model` NULL"))
    }
    not_init <- FALSE
    elmer_obj <- backend
    backend <- "elmer"
    model <- "chat"
  }
  if (is.null(backend) && !is.null(m_defaults_backend())) {
    if (m_defaults_backend() == "elmer") {
      args <- m_defaults_args()
      elmer_obj <- args[["elmer_obj"]]
      not_init <- FALSE
    }
  }
  if (not_init) {
    if (is.null(backend)) {
      try_connection <- test_connection()
      if (try_connection$status_code == 200) {
        ollama_models <- list_models()
        for (model in ollama_models$name) {
          models <- c(models, list(list(backend = "Ollama", model = model)))
        }
      }
    }
    if (length(models) == 0) {
      cli_abort("No backend was selected, and Ollama is not available")
    }
    sel_model <- 1
    if (length(models) > 1) {
      mu <- map_chr(models, function(x) glue("{x$backend} - {x$model}"))
      sel_model <- menu(mu)
      cli_inform("")
    }
    backend <- models[[sel_model]]$backend
    model <- models[[sel_model]]$model
  }
  if (.force) {
    cache <- .cache %||% tempfile("_mall_cache")
    m_defaults_reset()
  } else {
    cache <- .cache %||% m_defaults_cache() %||% tempfile("_mall_cache")
  }
  backend <- backend %||% m_defaults_backend()
  model <- model %||% m_defaults_model()
  m_defaults_set(backend = backend, model = model, .cache = cache, elmer_obj = elmer_obj, ...)
  if (!.silent || not_init) {
    print(m_defaults_get())
  }
  invisible(m_defaults_get())
}
