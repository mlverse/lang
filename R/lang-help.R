#' Translates help documentation to another language
#' @description
#' Translates a given topic into a target language. It uses the `lang` argument
#' to determine which language to translate to. If not passed, this function will
#' look for a target language in the LANG and LANGUAGE environment variables to
#' determine the target language. If the target language is English, no translation
#' will be processed, so the help returned will be the original package's
#' documentation.
#'
#' @param topic The topic to search for
#' @param package The R package to look for the topic
#' @param lang Language to translate the help to
#' @param type Produce "html" or "text" output for the help. It default to
#' `getOption("help_type")`
#' @examples
#' \donttest{ 
#'   library(lang)
#'   
#'   lang_use("ollama", "llama3.2", seed = 100)
#'   
#'   lang_help("lang_help", lang = "spanish", type = "text")
#' }
#' 
#' @export
lang_help <- function(topic,
                      package = NULL,
                      lang = NULL,
                      type = getOption("help_type")) {
  lang <- which_lang(lang)

  if (en_lang(lang)) {
    abort("Language already set to English, use `help()`")
  }

  if (is.null(package)) {
    # Gets the path to installed help file
    help_path <- as.character(utils::help(topic, help_type = "text"))
    # Tracks back two levels to figure out package name: .../[pkg]/help/[topic]
    help_pkg <- path_dir(path_dir(help_path))
    # Extracts name of package by using the name of its source folder
    package <- path_file(help_pkg)
  }
  topic_path <- rd_translate(topic, package, lang)
  structure(
    list(
      topic = topic,
      pkg = package,
      path = topic_path,
      stage = "render",
      type = type
    ),
    class = "lang_topic"
  )
}

#' @export
print.lang_topic <- function(x, ...) {
  type <- arg_match0(x$type %||% "text", c("text", "html"))
  if (type == "html" && rstudioapi_available()) {
    return(rstudioapi::callFun("previewRd", x$path))
  }
  if (type == "text") {
    Rd2txt(x$path)
  }
}

rstudioapi_available <- function() {
  is_installed("rstudioapi") && rstudioapi::isAvailable()
}

rd_translate <- function(topic, package, lang) {
  db <- Rd_db(package)
  rd_content <- db[[path(topic, ext = "Rd")]]
  tag_text <- NULL
  tag_name <- NULL
  tag_label <- NULL
  cli_progress_message("Translating: {.emph {tag_label}}")
  rs <- callr::r_session$new()
  lang_args <- lang_use_impl(.is_internal = TRUE)
  use_args <- list(
    backend = lang_args[["backend"]],
    model = lang_args[["model"]],
    .cache = lang_args[[".cache"]]
  )
  args <- lang_args[["args"]]
  if (length(args) > 0) {
    use_args <- c(use_args, args)
  }
  use_lang <- rs$run(
    function(x) {
      rlang::exec(mall::llm_use, !!!x)
    },
    args = list(x = use_args)
  )
  for (i in seq_along(rd_content)) {
    rd_i <- rd_content[[i]]
    tag_name <- attr(rd_i, "Rd_tag")
    standard_tags <- c(
      "\\title", "\\description",
      "\\value", "\\details",
      "\\seealso", "\\section"
    )
    if (tag_name == "\\section") {
      tag_label <- paste0("Section: '", as.character(rd_i[[1]]), "'")
    }
    if (is.null(tag_label)) {
      tag_label <- tag_to_label(tag_name)
    }
    tag_label <- to_title(tag_label)
    cli_progress_update()
    if (tag_name %in% standard_tags) {
      rd_content[[i]] <- rd_prep_translate(rd_i, lang, rs)
    }
    if (tag_name == "\\section") {
      rd_content[[i]][[1]] <- rd_prep_translate(rd_i[[1]], lang, rs)
      rd_content[[i]][[2]] <- rd_prep_translate(rd_i[[2]], lang, rs)
    }
    if (tag_name == "\\arguments") {
      for (k in seq_along(rd_i)) {
        rd_k <- rd_i[[k]]
        if (length(rd_k) > 1) {
          rd_i[[k]][[2]] <- rd_prep_translate(rd_k[[2]], lang, rs)
        }
      }
      rd_content[[i]] <- rd_i
    }
    if (tag_name == "\\name") {
      topic_name <- rd_i
    }
    if (tag_name == "\\examples") {
      for (k in seq_along(rd_i)) {
        rd_k <- rd_i[[k]]
        k_attrs <- attributes(rd_k)
        rd_char <- as.character(rd_k)
        if (inherits(rd_k, "list")) {
          rd_k <- lapply(rd_char, rd_comment_translate, lang, rs)
        }
        if (inherits(rd_k, "character")) {
          rd_k <- rd_comment_translate(rd_char, lang, rs)
        }
        attributes(rd_k) <- k_attrs
        rd_i[[k]] <- rd_k
      }
      rd_content[[i]] <- rd_i
    }
  }
  tag_name <- NULL
  rs$close()
  cli_progress_update()
  rd_text <- paste0(as.character(rd_content), collapse = "")
  topic_path <- fs::path(tempdir(), topic_name, ext = "Rd")
  writeLines(rd_text, topic_path)
  topic_path
}

rd_comment_translate <- function(x, lang, rs) {
  rd_char <- as.character(x)
  if (length(rd_char) == 1) {
    if (substr(rd_char, 1, 2) == "# ") {
      last_char <- substr(rd_char, nchar(rd_char), nchar(rd_char))
      n_char <- ifelse(last_char == "\n", 1, 0)
      rd_char <- substr(rd_char, 3, nchar(rd_char) - n_char)
      rd_char <- rs$run(
        function(x, language) mall::llm_vec_translate(x = x, language = language),
        args = list(x = rd_char, language = lang)
      )
      rd_char <- paste0("# ", rd_char, "\n")
    } else {

    }
    rd_char <- gsub("%", "\\\\%", rd_char)
    attributes(rd_char) <- attributes(x)
    x <- rd_char
  }
  x
}

rd_prep_translate <- function(x, lang, rs) {
  rd_text <- rd_extract_text(x)
  tag_text <- rs$run(
    function(x, language) {
      mall::llm_vec_translate(
        x = x,
        language = language,
        additional_prompt = paste(
          "Do not translate anything between single",
          "quotes. Do not translate the words: NULL,",
          "TRUE and FALSE"
        )
      )
    },
    args = list(x = rd_text, language = lang)
  )
  tag_text <- rd_code_markers(tag_text)
  tag_text <- gsub("`", "", tag_text)
  obj <- list(tag_text)
  attrs <- attributes(x[[1]])
  if (!is.null(attrs)) {
    attr(attrs, "Rd_tag") <- "TEXT"
    attributes(tag_text) <- attrs
  }
  attributes(obj) <- attributes(x)
  obj
}

rd_extract_text <- function(x, collapse = TRUE) {
  attributes(x) <- NULL
  class(x) <- "Rd"
  rd_text <- as.character(x)
  if (collapse) {
    rd_text <- paste0(as.character(x), collapse = "")
  }
  temp_rd <- tempfile(fileext = ".Rd")
  writeLines(rd_text, temp_rd)
  rd_txt <- capture.output(Rd2txt(temp_rd, fragment = TRUE))
  if (collapse) {
    rd_txt[rd_txt == ""] <- "\n\n"
    rd_txt <- paste0(rd_txt, collapse = "")
  }
  rd_txt <- gsub("\U2018", "'", rd_txt)
  rd_txt <- gsub("\U2019", "'", rd_txt)
  rd_txt
}

rd_code_markers <- function(x) {
  split_out <- strsplit(x, "'")[[1]]
  split_out
  new_txt <- NULL
  start_code <- TRUE
  for (i in seq_along(split_out)) {
    if (start_code) {
      if (i == length(split_out)) {
        code_txt <- NULL
      } else {
        code_txt <- "\\code{"
      }
      start_code <- FALSE
    } else {
      code_txt <- "}"
      start_code <- TRUE
    }
    new_txt <- c(new_txt, split_out[[i]], code_txt)
  }
  paste0(new_txt, collapse = "")
}
