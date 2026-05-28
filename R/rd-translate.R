lang_rs_refresh <- function(rs) {
  lang_args <- lang_use_impl(.is_internal = TRUE)
  backend <- lang_args[["backend"]]
  use_args <- list(.cache = lang_args[[".cache"]])
  if (!is.null(backend)) {
    use_args[["backend"]] <- backend
  }
  # Chat objects have their model built in; passing model separately is an error
  if (!inherits(backend, "Chat")) {
    use_args[["model"]] <- lang_args[["model"]]
  }
  args <- lang_args[["args"]]
  if (length(args) > 0) {
    use_args <- c(use_args, args)
  }
  rs$run(
    function(x) rlang::exec(mall::llm_use, !!!x),
    args = list(x = use_args)
  )
}

lang_rs_hash <- function() {
  s <- .lang_env$session
  paste(s[["backend"]], s[["model"]], s[[".cache"]], collapse = "|")
}

lang_rs_get <- function() {
  rs <- .lang_env$rs
  if (!is.null(rs) && rs$is_alive()) {
    if (rs$get_state() == "starting") {
      rs$poll_process(5000L)
    }
    if (rs$get_state() == "idle") {
      current_hash <- lang_rs_hash()
      if (!identical(.lang_env$rs_hash, current_hash)) {
        lang_rs_refresh(rs)
        .lang_env$rs_hash <- current_hash
      }
      return(rs)
    }
  }
  rs <- callr::r_session$new()
  .lang_env$rs <- rs
  lang_rs_refresh(rs)
  .lang_env$rs_hash <- lang_rs_hash()
  rs
}

rd_translate <- function(rd_content, lang, context_size) {
  rs <- lang_rs_get()

  lst <- rd_to_list(rd_content)
  nms <- names(lst)

  section_no <- 0L
  n_fields <- rd_count_fields(lst, context_size)
  tag_label <- ""
  progress_bar_init(
    total = rd_trans_size(lst),
    format = "[{section_no}/{n_fields}] {pb_bar} {pb_percent} | {tag_label}"
  )

  if (context_size >= 1L) {
    full_doc_text <- rd_flatten(lst)
    progress_bar_update("Context: Summarizing")
    summary_en <- rs$run(
      function(text, n) mall::llm_vec_summarize(text, max_words = n),
      args = list(text = full_doc_text, n = context_size)
    )
    section_no <- section_no + 1L
    progress_bar_update("Context: Translating summary")
    context_summary <- rs$run(
      function(x, lang) mall::llm_vec_translate(x, language = lang),
      args = list(x = summary_en, lang = lang)
    )
    section_no <- section_no + 1L
  } else {
    context_summary <- NULL
  }

  # Build shared prompt once (all fields use the same context block)
  context_block <- if (!is.null(context_summary)) {
    paste0(
      "For context, here is a short summary of the full help page in the target language:\n\n",
      context_summary,
      "\n\n"
    )
  } else {
    ""
  }
  add_prompt <- paste(
    context_block,
    "Do not translate anything between single quotes.",
    "Do not translate the words: NULL, TRUE, FALSE, NA, Nan.",
    "Do not expand on the subject, simply translate the original text"
  )

  # --- Collect all translatable texts into one vector ---

  prose_fields <- c(
    "title",
    "description",
    "details",
    "note",
    "author",
    "references",
    "seealso"
  )
  prose_present <- prose_fields[
    !vapply(lst[prose_fields], is.null, logical(1L))
  ]
  texts <- vapply(
    prose_present,
    function(f) paste(lst[[f]], collapse = "\n"),
    character(1L)
  )

  arg_start <- length(texts) + 1L
  texts <- c(
    texts,
    vapply(
      lst$arguments,
      function(a) paste(a$description, collapse = "\n"),
      character(1L)
    )
  )

  value_intro_pos <- NULL
  value_comp_start <- NULL
  value_outro_pos <- NULL
  if (!is.null(lst$value)) {
    v <- lst$value
    if (!is.null(v$intro) && nzchar(trimws(v$intro))) {
      value_intro_pos <- length(texts) + 1L
      texts <- c(texts, paste(v$intro, collapse = "\n"))
    }
    if (length(v$components) > 0L) {
      value_comp_start <- length(texts) + 1L
      texts <- c(
        texts,
        vapply(
          v$components,
          function(c) paste(c$description, collapse = "\n"),
          character(1L)
        )
      )
    }
    if (!is.null(v$outro) && nzchar(trimws(v$outro))) {
      value_outro_pos <- length(texts) + 1L
      texts <- c(texts, paste(v$outro, collapse = "\n"))
    }
  }

  sec_idx <- which(nms == "section")
  sec_labels <- character(length(sec_idx))
  sec_title_pos <- integer(length(sec_idx))
  sec_content_pos <- integer(length(sec_idx))
  for (i in seq_along(sec_idx)) {
    s <- lst[[sec_idx[[i]]]]
    tag_full <- s$title
    if (nchar(tag_full) > 17L) {
      tag_full <- paste0(substr(tag_full, 1L, 17L), "...")
    }
    sec_labels[[i]] <- tag_full
    sec_title_pos[[i]] <- length(texts) + 1L
    texts <- c(texts, paste(s$title, collapse = "\n"))
    sec_content_pos[[i]] <- length(texts) + 1L
    texts <- c(texts, paste(s$contents, collapse = "\n"))
  }

  ex_info <- list()
  if (!is.null(lst$examples)) {
    for (code_field in c("code_run", "code_dont_run")) {
      if (!is.null(lst$examples[[code_field]])) {
        lines <- strsplit(lst$examples[[code_field]], "\n", fixed = TRUE)[[1L]]
        cidx <- which(substr(lines, 1L, 2L) == "# ")
        if (length(cidx) > 0L) {
          ex_info[[code_field]] <- list(
            lines = lines,
            cidx = cidx,
            start = length(texts) + 1L,
            n = length(cidx)
          )
          texts <- c(texts, substr(lines[cidx], 3L, nchar(lines[cidx])))
        }
      }
    }
  }

  # --- One batch IPC call for all fields ---
  if (length(texts) > 0L) {
    translated <- rs$run(
      function(x, lang, prompt) {
        mall::llm_vec_translate(
          x = x,
          language = lang,
          additional_prompt = prompt
        )
      },
      args = list(x = texts, lang = lang, prompt = add_prompt)
    )

    # Distribute results back and update progress bar per field

    for (k in seq_along(prose_present)) {
      f <- prose_present[[k]]
      lst[[f]] <- translated[[k]]
      section_no <- section_no + 1L
      progress_bar_update(tag_to_label(f), obj = lst[[f]])
    }

    for (i in seq_along(lst$arguments)) {
      lst$arguments[[i]]$description <- translated[[arg_start + i - 1L]]
      section_no <- section_no + 1L
      progress_bar_update(
        glue("Argument: '{lst$arguments[[i]]$argument}'"),
        obj = lst$arguments[[i]]
      )
    }

    if (!is.null(lst$value)) {
      if (!is.null(value_intro_pos)) {
        lst$value$intro <- translated[[value_intro_pos]]
        section_no <- section_no + 1L
        progress_bar_update("Value", obj = lst$value$intro)
      }
      if (!is.null(value_comp_start)) {
        for (i in seq_along(lst$value$components)) {
          comp_name <- lst$value$components[[i]]$component
          lst$value$components[[i]]$description <- translated[[
            value_comp_start + i - 1L
          ]]
          section_no <- section_no + 1L
          progress_bar_update(
            glue("Value: '{comp_name}'"),
            obj = lst$value$components[[i]]
          )
        }
      }
      if (!is.null(value_outro_pos)) {
        lst$value$outro <- translated[[value_outro_pos]]
        section_no <- section_no + 1L
        progress_bar_update("Value", obj = lst$value$outro)
      }
    }

    for (i in seq_along(sec_idx)) {
      lst[[sec_idx[[i]]]]$title <- translated[[sec_title_pos[[i]]]]
      section_no <- section_no + 1L
      progress_bar_update(
        glue("Section: '{sec_labels[[i]]}'"),
        obj = lst[[sec_idx[[i]]]]$title
      )
      lst[[sec_idx[[i]]]]$contents <- translated[[sec_content_pos[[i]]]]
      section_no <- section_no + 1L
      progress_bar_update(
        glue("Section: '{sec_labels[[i]]}'"),
        obj = lst[[sec_idx[[i]]]]$contents
      )
    }

    for (code_field in names(ex_info)) {
      info <- ex_info[[code_field]]
      info$lines[info$cidx] <- paste0(
        "# ",
        translated[info$start:(info$start + info$n - 1L)]
      )
      lst$examples[[code_field]] <- paste(info$lines, collapse = "\n")
    }
  }

  if (!is.null(lst$examples)) {
    section_no <- section_no + 1L
    progress_bar_update("Examples")
  }

  cli_progress_done()
  cli_alert_success("{.pkg lang} - {.emph Translation complete}")

  rd_str <- list_to_rd(lst)
  tmp <- tempfile(fileext = ".Rd")
  writeLines(rd_str, tmp)
  tmp
}

rd_field_translate <- function(x, lang, rs, context_summary = NULL) {
  context_block <- if (!is.null(context_summary)) {
    paste0(
      "For context, here is a short summary of the full help page in the target language:\n\n",
      context_summary,
      "\n\n"
    )
  } else {
    ""
  }
  add_prompt <- paste(
    context_block,
    "Do not translate anything between single quotes.",
    "Do not translate the words: NULL, TRUE, FALSE, NA, Nan.",
    "Do not expand on the subject, simply translate the original text"
  )
  rs$run(
    function(x, y, z) {
      mall::llm_vec_translate(x = x, language = y, additional_prompt = z)
    },
    args = list(x = paste(x, collapse = "\n"), y = lang, z = add_prompt)
  )
}

rd_examples_translate <- function(code, lang, rs, context_summary = NULL) {
  lines <- strsplit(code, "\n", fixed = TRUE)[[1L]]
  comment_idx <- which(substr(lines, 1L, 2L) == "# ")
  if (length(comment_idx) == 0L) {
    return(code)
  }
  context_block <- if (!is.null(context_summary)) {
    paste0(
      "For context, here is a short summary of the full help page in the target language:\n\n",
      context_summary,
      "\n\n"
    )
  } else {
    ""
  }
  comment_texts <- substr(lines[comment_idx], 3L, nchar(lines[comment_idx]))
  translated <- rs$run(
    function(x, language, context) {
      mall::llm_vec_translate(
        x = x,
        language = language,
        additional_prompt = context
      )
    },
    args = list(x = comment_texts, language = lang, context = context_block)
  )
  lines[comment_idx] <- paste0("# ", translated)
  paste(lines, collapse = "\n")
}

rd_trans_size <- function(lst) {
  nms <- names(lst)
  size <- 0L
  for (field in c(
    "title",
    "description",
    "details",
    "note",
    "author",
    "references",
    "seealso"
  )) {
    if (!is.null(lst[[field]])) {
      size <- size + as.integer(object.size(lst[[field]]))
    }
  }
  for (i in seq_along(lst$arguments)) {
    size <- size + as.integer(object.size(lst$arguments[[i]]))
  }
  if (!is.null(lst$value)) {
    v <- lst$value
    if (!is.null(v$intro) && nzchar(trimws(v$intro))) {
      size <- size + as.integer(object.size(v$intro))
    }
    for (i in seq_along(v$components)) {
      size <- size + as.integer(object.size(v$components[[i]]))
    }
    if (!is.null(v$outro) && nzchar(trimws(v$outro))) {
      size <- size + as.integer(object.size(v$outro))
    }
  }
  sec_idx <- which(nms == "section")
  for (i in seq_along(sec_idx)) {
    s <- lst[[sec_idx[[i]]]]
    size <- size + as.integer(object.size(s$title))
    size <- size + as.integer(object.size(s$contents))
  }
  size
}

rd_count_fields <- function(lst, context_size = 0L) {
  nms <- names(lst)
  n <- 0L
  for (field in c(
    "title",
    "description",
    "details",
    "note",
    "author",
    "references",
    "seealso"
  )) {
    if (!is.null(lst[[field]])) {
      n <- n + 1L
    }
  }
  n <- n + length(lst$arguments)
  if (!is.null(lst$value)) {
    v <- lst$value
    if (!is.null(v$intro) && nzchar(trimws(v$intro))) {
      n <- n + 1L
    }
    n <- n + length(v$components)
    if (!is.null(v$outro) && nzchar(trimws(v$outro))) {
      n <- n + 1L
    }
  }
  n <- n + length(which(nms == "section")) * 2L
  if (!is.null(lst$examples)) {
    n <- n + 1L
  }
  if (context_size >= 1L) {
    n <- n + 2L
  }
  n
}

to_title <- function(x) {
  x |>
    strsplit(" ") |>
    unlist() |>
    map(
      \(x) {
        up <- toupper(x)
        lo <- tolower(x)
        paste0(substr(up, 1, 1), substr(lo, 2, nchar(lo)))
      }
    ) |>
    as.character() |>
    paste0(collapse = " ")
}

tag_to_label <- function(x) {
  x <- gsub("\\\\", "", x)
  tag_labels <- c(
    "title" = "Title",
    "description" = "Description",
    "value" = "Value",
    "details" = "Details",
    "note" = "Note",
    "seealso" = "See Also",
    "examples" = "Examples",
    "arguments" = "Arguments",
    "usage" = "Usage",
    "output" = "Output",
    "returns" = "Returns",
    "return" = "Return",
    "author" = "Author",
    "references" = "References"
  )
  match <- tag_labels[names(tag_labels) == x]
  if (length(match) > 0) {
    x <- as.character(match)
  }
  to_title(x)
}

# This is for mock testing purposes
is_interactive <- function() interactive()

progress_bar_init <- function(total, format, envir = parent.frame()) {
  if (is_interactive()) {
    .lang_env$size <- total
    .lang_env$progress <- 0
    cli_progress_bar(
      total = total,
      format = format,
      auto_terminate = FALSE,
      .envir = envir
    )
  }
}

progress_bar_update <- function(
  txt = NULL,
  obj = NULL,
  envir = parent.frame()
) {
  if (is_interactive()) {
    if (is.null(obj)) {
      set <- NULL
    } else {
      total_size <- .lang_env$size
      curr_progress <- as.integer(object.size(obj)) + .lang_env$progress
      if (curr_progress > total_size) {
        .lang_env$progress <- total_size
      } else {
        .lang_env$progress <- curr_progress
      }
      set <- .lang_env$progress
    }
    if (!is.null(txt)) {
      envir$tag_label <- txt
    }
    cli_progress_update(set = set, .envir = envir)
  }
}
