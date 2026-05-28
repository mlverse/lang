# Render a single Rd node to plain text via Rd2txt().
.rd_extract_text <- function(x, collapse = TRUE) {
  rd_tag <- attr(x, "Rd_tag") %||% ""
  if (rd_tag == "\\dots") {
    return(" ...")
  }
  attributes(x) <- NULL
  class(x) <- "Rd"
  rd_text <- if (collapse) {
    paste0(as.character(x), collapse = "")
  } else {
    as.character(x)
  }
  tmp <- tempfile(fileext = ".Rd")
  on.exit(unlink(tmp), add = TRUE)
  writeLines(rd_text, tmp)
  old <- options(useFancyQuotes = TRUE)
  on.exit(options(old), add = TRUE)
  rd_txt <- suppressWarnings(capture.output(Rd2txt(tmp, fragment = TRUE)))
  if (collapse) {
    rd_txt <- paste0(rd_txt, collapse = " ")
  }
  rd_txt <- gsub("‘", "`", rd_txt)
  rd_txt <- gsub("’", "`", rd_txt)
  rd_txt
}

# Render a single Rd node to a character vector of lines via Rd2txt().
.rd_extract_text2 <- function(x, collapse = TRUE, trim = "full") {
  old <- options(useFancyQuotes = TRUE)
  on.exit(options(old), add = TRUE)
  rd_txt <- tryCatch(
    capture.output(Rd2txt(list(x), fragment = TRUE)),
    error = function(e) NULL
  )
  if (is.null(rd_txt) || length(rd_txt) == 0L) {
    return(as.character(x))
  }
  rd_txt <- gsub("‘", "`", rd_txt)
  rd_txt <- gsub("’", "`", rd_txt)
  if (trim == "tab") {
    tabbed <- substr(rd_txt, 1L, 5L) == "     "
    rd_txt[tabbed] <- substr(rd_txt[tabbed], 6L, nchar(rd_txt[tabbed]))
  }
  if (trim == "full") {
    rd_txt <- trimws(rd_txt)
  }
  rd_txt <- rd_txt[seq(2L, length(rd_txt))]
  if (length(rd_txt) && rd_txt[[1L]] == "") {
    rd_txt <- rd_txt[-1L]
  }
  if (length(rd_txt) && rd_txt[[length(rd_txt)]] == "") {
    rd_txt <- rd_txt[-length(rd_txt)]
  }
  if (collapse) {
    rd_txt[rd_txt == ""] <- "xxxx"
    rd_txt <- paste(rd_txt, collapse = " ")
    rd_txt <- unlist(strsplit(rd_txt, "xx"))
  }
  rd_txt
}

# Parse \arguments{} items into a list of list(argument, description).
.rd_args_process <- function(x) {
  discard(
    map(x, function(item) {
      name <- .rd_extract_text(item[1L])
      val <- .rd_extract_text(item[2L])
      if (nzchar(name)) {
        list(argument = name, description = val)
      } else {
        NULL
      }
    }),
    is.null
  )
}

# Parse \value{} into list(intro, components, outro).
.rd_value_process <- function(x) {
  child_tags <- vapply(x, attr, "", "Rd_tag")
  item_idx <- which(child_tags == "\\item")

  if (length(item_idx) == 0L) {
    return(list(
      intro = paste(.rd_extract_text2(x), collapse = "\n"),
      components = list(),
      outro = ""
    ))
  }

  first_item <- item_idx[[1L]]
  last_item <- item_idx[[length(item_idx)]]

  render_nodes <- function(nodes) {
    if (length(nodes) == 0L) {
      return("")
    }
    sub_rd <- nodes
    class(sub_rd) <- "Rd"
    txt <- tryCatch(
      capture.output(Rd2txt(sub_rd, fragment = TRUE)),
      error = function(e) character(0L)
    )
    txt <- txt[nzchar(trimws(txt))]
    paste(trimws(txt), collapse = " ")
  }

  intro <- render_nodes(x[seq_len(first_item - 1L)])
  if (last_item < length(x)) {
    outro <- render_nodes(x[seq(last_item + 1L, length(x))])
  } else {
    outro <- ""
  }

  components <- discard(
    map(x[item_idx], function(item) {
      name <- .rd_extract_text(item[1L])
      desc <- .rd_extract_text(item[2L])
      if (nzchar(name)) {
        list(component = name, description = desc)
      } else {
        NULL
      }
    }),
    is.null
  )

  list(intro = intro, components = components, outro = outro)
}

# Dispatch per Rd tag; returns a named list fragment.
.rd_tag_process <- function(x) {
  out <- list()
  tag_name <- attr(x, "Rd_tag")
  x_str <- as.character(x)[[1L]]

  src_prefix <- "% Please edit documentation in "
  if (grepl(src_prefix, x_str, fixed = TRUE)) {
    x_str <- substr(x_str, nchar(src_prefix), nchar(x_str))
    out <- list(source = trimws(x_str))
  }

  if (grepl("\\\\", tag_name)) {
    tag_name <- substr(tag_name, 2L, nchar(tag_name))
    tag_text <- switch(
      tag_name,
      "arguments" = list(.rd_args_process(x)),
      "value" = list(.rd_value_process(x)),
      "usage" = list(.rd_extract_text2(x, collapse = FALSE, trim = "tab")),
      "alias" = list(.rd_extract_text(x)),
      "examples" = {
        rd_tags <- map_chr(x, attr, "Rd_tag")
        run <- if ("\\donttest" %in% rd_tags || "\\dontrun" %in% rd_tags) {
          "code_dont_run"
        } else {
          "code_run"
        }
        list(set_names(
          list(trimws(paste0(reduce(map(x, as.character), c), collapse = ""))),
          run
        ))
      },
      "section" = list(list(
        title = as.character(x[[1L]]),
        contents = .rd_extract_text2(x)
      )),
      list(.rd_extract_text2(x))
    )
    out <- set_names(tag_text, tag_name)
  }
  out
}

rd_to_list <- function(rd) {
  if (inherits(rd, "Rd")) {
    rd_content <- rd
  } else {
    rd_content <- parse_Rd(rd)
  }
  do.call(c, keep(map(rd_content, .rd_tag_process), function(x) length(x) > 0))
}

rd_flatten <- function(lst) {
  lines <- character()
  h <- function(tag) lines <<- c(lines, paste0("[[", tag, "]]"))
  l <- function(...) lines <<- c(lines, paste0(...))
  br <- function() lines <<- c(lines, "")
  nms <- names(lst)

  if (!is.null(lst$title)) {
    h("title")
    l(lst$title)
    br()
  }
  if (!is.null(lst$description)) {
    h("description")
    for (line in lst$description) {
      l(line)
    }
    br()
  }
  if (length(lst$arguments)) {
    for (a in lst$arguments) {
      l("[[", a$argument, "]]")
      l(a$description)
      br()
    }
  }
  if (!is.null(lst$details)) {
    h("details")
    for (line in lst$details) {
      l(line)
    }
    br()
  }
  if (!is.null(lst$value)) {
    v <- lst$value
    if (!is.null(v$intro) && nzchar(trimws(v$intro))) {
      h("value.intro")
      l(v$intro)
      br()
    }
    if (length(v$components)) {
      for (co in v$components) {
        l("[[", co$component, "]]")
        l(co$description)
        br()
      }
    }
    if (!is.null(v$outro) && nzchar(trimws(v$outro))) {
      h("value.outro")
      l(v$outro)
      br()
    }
  }
  sec_items <- lst[nms == "section"]
  for (i in seq_along(sec_items)) {
    s <- sec_items[[i]]
    h(paste0("section.", i, ".title"))
    l(s$title)
    br()
    h(paste0("section.", i, ".body"))
    for (line in s$contents) {
      l(line)
    }
    br()
  }
  for (field in c("author", "references", "seealso")) {
    vals <- lst[[field]]
    if (!is.null(vals)) {
      h(field)
      for (line in vals) {
        l(line)
      }
      br()
    }
  }
  paste(lines, collapse = "\n")
}

# Re-encode backtick spans to \code{} and escape bare %.
.rd_clean <- function(x) {
  x <- gsub("`([^`\n]+)`", "\\\\code{\\1}", x)
  x <- gsub("(?<!\\\\)%", "\\\\%", x, perl = TRUE)
  x
}

list_to_rd <- function(lst) {
  lines <- character()
  emit <- function(...) lines <<- c(lines, ...)
  nms <- names(lst)

  emit(sprintf("\\name{%s}", lst$name %||% ""))
  for (a in unlist(lst[nms == "alias"])) {
    emit(sprintf("\\alias{%s}", a))
  }
  for (kw in unlist(lst[nms == "concept"])) {
    emit(sprintf("\\concept{%s}", kw))
  }
  for (kw in unlist(lst[nms == "keyword"])) {
    emit(sprintf("\\keyword{%s}", kw))
  }

  if (!is.null(lst$title)) {
    emit(sprintf("\\title{%s}", .rd_clean(paste(lst$title, collapse = " "))))
  }
  if (!is.null(lst$description)) {
    emit(
      "\\description{",
      .rd_clean(paste(lst$description, collapse = "\n")),
      "}"
    )
  }
  if (!is.null(lst$usage)) {
    emit("\\usage{", paste(lst$usage, collapse = "\n"), "}")
  }
  if (length(lst$arguments)) {
    emit("\\arguments{")
    for (a in lst$arguments) {
      emit(sprintf(
        "  \\item{%s}{%s}",
        a$argument,
        .rd_clean(paste(a$description, collapse = " "))
      ))
    }
    emit("}")
  }
  if (!is.null(lst$details)) {
    emit("\\details{", .rd_clean(paste(lst$details, collapse = "\n")), "}")
  }
  if (!is.null(lst$value)) {
    v <- lst$value
    emit("\\value{")
    if (!is.null(v$intro) && nzchar(trimws(v$intro))) {
      emit(.rd_clean(v$intro))
    }
    for (co in v$components %||% list()) {
      emit(sprintf(
        "  \\item{%s}{%s}",
        co$component,
        .rd_clean(paste(co$description, collapse = " "))
      ))
    }
    if (!is.null(v$outro) && nzchar(trimws(v$outro))) {
      emit(.rd_clean(v$outro))
    }
    emit("}")
  }
  if (!is.null(lst$note)) {
    emit("\\note{", .rd_clean(paste(lst$note, collapse = "\n")), "}")
  }
  for (s in lst[nms == "section"]) {
    emit(
      sprintf("\\section{%s}{", .rd_clean(s$title)),
      .rd_clean(paste(s$contents, collapse = "\n")),
      "}"
    )
  }
  if (!is.null(lst$author)) {
    emit("\\author{", .rd_clean(paste(lst$author, collapse = "\n")), "}")
  }
  if (!is.null(lst$references)) {
    emit(
      "\\references{",
      .rd_clean(paste(lst$references, collapse = "\n")),
      "}"
    )
  }
  if (!is.null(lst$seealso)) {
    emit("\\seealso{", .rd_clean(paste(lst$seealso, collapse = "\n")), "}")
  }
  if (!is.null(lst$examples)) {
    ex <- lst$examples
    emit("\\examples{")
    if (!is.null(ex$code_dont_run)) {
      emit("\\donttest{", ex$code_dont_run, "}")
    } else if (!is.null(ex$code_run)) {
      emit(ex$code_run)
    }
    emit("}")
  }

  paste(lines, collapse = "\n")
}
