rd_translate <- function(rd_content, lang) {
  rs <- callr::r_session$new()
  on.exit(rs$close())
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
    function(x) rlang::exec(mall::llm_use, !!!x),
    args = list(x = use_args)
  )
  standard_tags <- c(
    "\\title", "\\description", "\\arguments", "\\value",
    "\\details", "\\seealso", "\\note", "\\author"
  )
  non_standard_tags <- c("\\section", "\\examples")
  all_tags <- as.character(lapply(rd_content, function(x) attr(x, "Rd_tag")))
  filter_obj <- lapply(
    c(standard_tags, non_standard_tags),
    function(x) rd_content[all_tags == x]
  )
  section_no <- 0
  obj_total <- as.integer(object.size(filter_obj))
  cli_progress_bar_int(
    total = obj_total,
    format = "[{section_no}/{length(filter_obj)}] {pb_bar} {pb_percent} | {tag_label}"
  )
  obj_progress <- 0
  for (i in seq_along(rd_content)) {
    rd_i <- rd_content[[i]]
    tag_name <- attr(rd_i, "Rd_tag")
    if (tag_name %in% c(standard_tags, non_standard_tags)) {
      section_no <- section_no + 1
      tag_label <- NULL
      tag_label <- tag_name
      if (tag_name %in% standard_tags) {
        tag_label <- tag_to_label(tag_name)
        cli_progress_update_int()
        if (any(lapply(rd_i, attr, "Rd_tag") == "\\item")) {
          for (k in seq_along(rd_i)) {
            rd_k <- rd_i[[k]]
            if (length(rd_k) > 1) {
              rd_content[[i]][[k]][[2]] <- rd_prep_translate(rd_k[[2]], lang, rs)
            } else {
              item_translation <- suppressWarnings(
                try(rd_prep_translate(rd_k, lang, rs), silent = TRUE)
              )
              if (!inherits(item_translation, "try-error")) {
                rd_content[[i]][[k]] <- item_translation
              }
            }
          }
        } else {
          rd_content[[i]] <- rd_prep_translate(rd_i, lang, rs)
        }
      }
      if (tag_name == "\\section") {
        tag_full <- rd_extract_text(rd_i[[1]], rs)
        if (nchar(tag_full > 17)) {
          tag_full <- paste0(substr(tag_full, 1, 17), "...")
        }
        tag_label <- paste0("Section: '", tag_full, "'")
        rd_content[[i]][[1]] <- rd_prep_translate(rd_i[[1]], lang, rs)
        rd_content[[i]][[2]] <- rd_prep_translate(rd_i[[2]], lang, rs)
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
      obj_progress <- obj_progress + as.integer(object.size(rd_i))
      if (obj_progress > obj_total) {
        obj_progress <- obj_total
      }
      cli_progress_update_int(set = obj_progress)
    }
    if (tag_name == "\\name") {
      topic_name <- rd_i
    }
  }
  tag_name <- NULL
  rs$close()
  rd_text <- paste0(as.character(rd_content), collapse = "")
  topic_path <- path(tempdir(), topic_name, ext = "Rd")
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
  txt <- rd_extract_text(x, rs)
  rd_text <- gsub("\U2018", "'", txt)
  rd_text <- gsub("\U2019", "'", rd_text)
  add_prompt <- paste(
    "Do not translate anything between single quotes.",
    "Do not translate the words: NULL, TRUE, FALSE, NA, Nan.",
    "Do not expand on the subject, simply translate the original text"
  )
  tag_text <- rs$run(
    function(x, y, z) {
      mall::llm_vec_translate(x = x, language = y, additional_prompt = z)
    },
    args = list(x = rd_text, y = lang, z = add_prompt)
  )
  funcs <- unlist(strsplit(txt, "\U2018"))
  funcs <- lapply(funcs, strsplit, "\U2019")
  funcs <- lapply(funcs, unlist)
  funcs <- funcs[as.numeric(lapply(funcs, length)) == 2]
  funcs <- lapply(funcs, head, 1)
  for (func in funcs) {
    func <- sub("\\(", "\\\\(", func)
    func <- sub("\\)", "\\\\)", func)
    tag_text <- sub(paste0("'", func, "'"), paste0("\\\\code{", func, "}"), tag_text)
  }
  obj <- list(tag_text)
  attrs <- attributes(x[[1]])
  if (!is.null(attrs)) {
    attr(attrs, "Rd_tag") <- "TEXT"
    attributes(tag_text) <- attrs
  }
  attributes(obj) <- attributes(x)
  obj
}

rd_extract_text <- function(x, rs) {
  txt <- rs$run(
    function(x) {
      tools::Rd2txt_options(width = Inf)
      capture.output(tools::Rd2txt(x, fragment = TRUE))
    },
    args = list(x = x)
  )
  txt <- gsub("_\b", "", txt)
  paste0(txt, collapse = "\n\n")
}

rd_code_markers <- function(x) {
  x <- gsub("\U2018", "'", x)
  x <- gsub("\U2019", "'", x)
  split_out <- strsplit(x, "'")[[1]]
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

to_title <- function(x) {
  split_x <- strsplit(x, " ")[[1]]
  split_title <- lapply(
    split_x,
    function(x) {
      up <- toupper(x)
      lo <- tolower(x)
      paste0(substr(up, 1, 1), substr(lo, 2, nchar(lo)))
    }
  )
  paste0(as.character(split_title), collapse = " ")
}

tag_to_label <- function(x) {
  x <- gsub("\\\\", "", x)
  tag_labels <- c(
    "title" = "Title",
    "description" = "Description",
    "value" = "Value",
    "details" = "Details",
    "seealso" = "See Also",
    "examples" = "Examples",
    "arguments" = "Arguments",
    "usage" = "Usage",
    "output" = "Output",
    "returns" = "Returns",
    "return" = "Return",
    "seealso" = "See Also"
  )
  match <- tag_labels[names(tag_labels) == x]
  if (length(match) > 0) {
    x <- as.character(match)
  }
  to_title(x)
}

cli_progress_bar_int <- function(..., envir = parent.frame()) {
  if (interactive()) {
    cli_progress_bar(..., .envir = envir)
  }
}

cli_progress_update_int <- function(..., envir = parent.frame()) {
  if (interactive()) {
    cli_progress_update(..., .envir = envir)
  }
}
