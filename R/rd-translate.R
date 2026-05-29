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
  lst <- rd_to_list(rd_content)
  nms <- names(lst)

  tag_label <- "Initializing..."
  progress_bar_init(
    total = rd_trans_size(lst, context_size),
    format = "{pb_bar} {pb_percent} | {tag_label}"
  )

  rs <- lang_rs_get()

  if (context_size >= 1L) {
    full_doc_text <- rd_flatten(lst)
    progress_bar_update("Context: Summarizing")
    summary_en <- rs$run(
      function(text, n) mall::llm_vec_summarize(text, max_words = n),
      args = list(text = full_doc_text, n = context_size)
    )
    progress_bar_update("Context: Summarizing", obj = summary_en)
    progress_bar_update("Context: Translating summary")
    context_summary <- rs$run(
      function(x, lang) mall::llm_vec_translate(x, language = lang),
      args = list(x = summary_en, lang = lang)
    )
    progress_bar_update("Context: Translating summary", obj = context_summary)
  } else {
    context_summary <- NULL
  }

  # Prose fields
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
      progress_bar_update(tag_to_label(field))
      lst[[field]] <- rd_field_translate(
        lst[[field]],
        lang,
        rs,
        context_summary
      )
      progress_bar_update(tag_to_label(field), obj = lst[[field]])
    }
  }

  # Arguments
  for (i in seq_along(lst$arguments)) {
    arg_name <- lst$arguments[[i]]$argument
    progress_bar_update(glue("Argument: '{arg_name}'"))
    lst$arguments[[i]]$description <- rd_field_translate(
      lst$arguments[[i]]$description,
      lang,
      rs,
      context_summary
    )
    progress_bar_update(
      glue("Argument: '{arg_name}'"),
      obj = lst$arguments[[i]]$description
    )
  }

  # Value
  if (!is.null(lst$value)) {
    v <- lst$value
    if (!is.null(v$intro) && nzchar(trimws(v$intro))) {
      progress_bar_update("Value")
      lst$value$intro <- rd_field_translate(v$intro, lang, rs, context_summary)
      progress_bar_update("Value", obj = lst$value$intro)
    }
    for (i in seq_along(v$components)) {
      comp_name <- v$components[[i]]$component
      progress_bar_update(glue("Value: '{comp_name}'"))
      lst$value$components[[i]]$description <- rd_field_translate(
        v$components[[i]]$description,
        lang,
        rs,
        context_summary
      )
      progress_bar_update(
        glue("Value: '{comp_name}'"),
        obj = lst$value$components[[i]]$description
      )
    }
    if (!is.null(v$outro) && nzchar(trimws(v$outro))) {
      progress_bar_update("Value")
      lst$value$outro <- rd_field_translate(v$outro, lang, rs, context_summary)
      progress_bar_update("Value", obj = lst$value$outro)
    }
  }

  # Named sections
  sec_idx <- which(nms == "section")
  for (i in seq_along(sec_idx)) {
    s <- lst[[sec_idx[[i]]]]
    tag_full <- s$title
    if (nchar(tag_full) > 17L) {
      tag_full <- paste0(substr(tag_full, 1L, 17L), "...")
    }
    lbl <- glue("Section: '{tag_full}'")
    progress_bar_update(lbl)
    lst[[sec_idx[[i]]]]$title <- rd_field_translate(
      s$title,
      lang,
      rs,
      context_summary
    )
    progress_bar_update(lbl, obj = lst[[sec_idx[[i]]]]$title)
    progress_bar_update(lbl)
    lst[[sec_idx[[i]]]]$contents <- rd_field_translate(
      s$contents,
      lang,
      rs,
      context_summary
    )
    progress_bar_update(lbl, obj = lst[[sec_idx[[i]]]]$contents)
  }

  # Examples — translate # comments only
  if (!is.null(lst$examples)) {
    progress_bar_update("Examples")
    if (!is.null(lst$examples$code_run)) {
      lst$examples$code_run <- rd_examples_translate(
        lst$examples$code_run,
        lang,
        rs,
        context_summary
      )
    }
    if (!is.null(lst$examples$code_dont_run)) {
      lst$examples$code_dont_run <- rd_examples_translate(
        lst$examples$code_dont_run,
        lang,
        rs,
        context_summary
      )
    }
    progress_bar_update("Examples", obj = lst$examples)
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

rd_trans_size <- function(lst, context_size = 0L) {
  nms <- names(lst)
  size <- 0L
  prose_fields <- c(
    "title",
    "description",
    "details",
    "note",
    "author",
    "references",
    "seealso"
  )
  for (field in prose_fields) {
    if (!is.null(lst[[field]])) {
      size <- size + as.integer(object.size(lst[[field]]))
    }
  }
  for (i in seq_along(lst$arguments)) {
    size <- size + as.integer(object.size(lst$arguments[[i]]$description))
  }
  if (!is.null(lst$value)) {
    v <- lst$value
    if (!is.null(v$intro) && nzchar(trimws(v$intro))) {
      size <- size + as.integer(object.size(v$intro))
    }
    for (i in seq_along(v$components)) {
      size <- size + as.integer(object.size(v$components[[i]]$description))
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
  if (!is.null(lst$examples)) {
    size <- size + as.integer(object.size(lst$examples))
  }
  if (context_size >= 1L) {
    full_doc_text <- rd_flatten(lst)
    size <- size + 2L * as.integer(object.size(full_doc_text))
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
    cli_progress_update(set = 0L, force = TRUE, .envir = envir)
  }
}

progress_bar_update <- function(
  txt = NULL,
  obj = NULL,
  envir = parent.frame()
) {
  if (is_interactive()) {
    if (!is.null(obj)) {
      total_size <- .lang_env$size
      curr_progress <- as.integer(object.size(obj)) + .lang_env$progress
      .lang_env$progress <- min(curr_progress, total_size)
    }
    if (!is.null(txt)) {
      envir$tag_label <- txt
    }
    cli_progress_update(set = .lang_env$progress, force = TRUE, .envir = envir)
  }
}
