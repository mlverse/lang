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
  rs$run(
    function(x) rlang::exec(mall::llm_use, !!!x),
    args = list(x = use_args)
  )

  lst <- rd_to_list(rd_content)
  nms <- names(lst)

  tag_label <- ""
  progress_bar_init(
    total = rd_count_fields(lst),
    format = "[{pb_current}/{pb_total}] {pb_bar} {pb_percent} | {tag_label}"
  )

  # Prose scalar / vector fields
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
      lst[[field]] <- rd_field_translate(lst[[field]], lang, rs)
    }
  }

  # Arguments
  for (i in seq_along(lst$arguments)) {
    arg_name <- lst$arguments[[i]]$argument
    progress_bar_update(glue("Argument: '{arg_name}'"))
    lst$arguments[[i]]$description <- rd_field_translate(
      lst$arguments[[i]]$description,
      lang,
      rs
    )
  }

  # Value
  if (!is.null(lst$value)) {
    v <- lst$value
    if (!is.null(v$intro) && nzchar(trimws(v$intro))) {
      progress_bar_update("Value")
      lst$value$intro <- rd_field_translate(v$intro, lang, rs)
    }
    for (i in seq_along(v$components)) {
      comp_name <- v$components[[i]]$component
      progress_bar_update(glue("Value: '{comp_name}'"))
      lst$value$components[[i]]$description <- rd_field_translate(
        v$components[[i]]$description,
        lang,
        rs
      )
    }
    if (!is.null(v$outro) && nzchar(trimws(v$outro))) {
      progress_bar_update("Value")
      lst$value$outro <- rd_field_translate(v$outro, lang, rs)
    }
  }

  # Named sections
  sec_idx <- which(nms == "section")
  for (i in seq_along(sec_idx)) {
    s <- lst[[sec_idx[[i]]]]
    tag_full <- s$title
    if (nchar(tag_full) > 17) {
      tag_full <- paste0(substr(tag_full, 1, 17), "...")
    }
    progress_bar_update(glue("Section: '{tag_full}'"))
    lst[[sec_idx[[i]]]]$title <- rd_field_translate(s$title, lang, rs)
    progress_bar_update(glue("Section: '{tag_full}'"))
    lst[[sec_idx[[i]]]]$contents <- rd_field_translate(s$contents, lang, rs)
  }

  cli_progress_done()
  cli_alert_success("{.pkg lang} - {.emph Translation complete}")

  rd_str <- list_to_rd(lst)
  tmp <- tempfile(fileext = ".Rd")
  writeLines(rd_str, tmp)
  tmp
}

rd_field_translate <- function(x, lang, rs) {
  add_prompt <- paste(
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

rd_count_fields <- function(lst) {
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
    cli_progress_bar(total = total, format = format, .envir = envir)
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
