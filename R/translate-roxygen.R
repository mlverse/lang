#' Translates the Roxygen2 documentation
#' @description
#' Reads the Roxygen2 tags in the package and translates them. The translations
#' are stored in R scripts. The default location of the new scripts is 'man-lang'.
#' The will be in a sub-folder representing the language the are translated to.
#'
#' @details This approach makes it easier to edit the translations by hand after
#' the LLM does a first pass. It also allows for others to collaborate
#' with improving the translation.
#' @param lang The target language to translate help to
#' @param folder 2-letter language/source folder to save the new
#' Roxygen scripts to.
#' @param target The target base folder to save the Roxygen files. It defaults
#' to 'man-lang'. The final destination will be a combination of this and the
#' folder from `folder`
#' @param source The source R scripts. It defaults to the 'R' folder.
#'
#' @export
translate_roxygen <- function(
    lang,
    folder,
    target = path("man-lang"),
    source = path("R")) {
  if (nchar(folder) != 2) {
    cli_abort("Use an ISO 639 2 character language code for `folder`")
  }
  if (!is_dir(source)) {
    cli_abort("`source` needs to be a valid directory")
  }
  target <- path(target, folder)
  dir_create(target)
  cli_h3("`lang` translating Roxygen into '{lang}'")
  r_files <- dir_ls(source, glob = "*.R")
  pkg_env <- env_package(source)
  for (i in seq_along(r_files)) {
    translate_roxygen_imp(
      path = r_files[[i]],
      lang = lang,
      dir = target,
      no = i,
      of = length(r_files),
      pkg_env = pkg_env
    )
  }
}


#' @rdname translate_roxygen
#' @param path The path to the R script containing the Roxygen help
#' documentation
#' @param target_path The path to write the new, translated, R script to. The
#' name of the file will match that of the original R script.
#' @export
translate_roxygen_file <- function(path, lang, target_path) {
  translate_roxygen_imp(
    path = path,
    lang = lang,
    dir = target_path
  )
}

translate_roxygen_imp <- function(path,
                                  lang = NULL,
                                  dir,
                                  no = 1,
                                  of = 1,
                                  pkg_env = NULL) {
  if (is.null(pkg_env)) {
    if (is_dir(path)) {
      pkg_path <- path_dir(path)
    } else {
      pkg_path <- path_dir(path_dir(path))
    }
    pkg_env <- env_package(pkg_path)
  }
  dir_create(dir)
  rd_path <- path(dir, path_file(path))
  cli_inform("[{no}/{of}] {path} --> {rd_path}")
  parsed <- parse_file(path, env = pkg_env)
  contents <- NULL
  tg_label <- NULL
  cli_progress_message("Translating: {.emph {tg_label}}")
  for (roxy in parsed) {
    tg <- NULL
    for (tag in roxy$tags) {
      tg <- tag$tag
      raw <- tag$raw
      if (tg == "param") {
        name <- glue(" {tag$val$name} ")
        tg_label <- glue("Argument: {name}")
      } else {
        name <- NULL
        tg_label <- tag_to_label(tg)
      }
      if (tg == "section") {
        split_raw <- unlist(strsplit(raw, "\\:"))
        section_title <- split_raw[[1]]
        section_content <- substr(raw, nchar(section_title) + 2, nchar(raw))
        raw <- c(section_title, section_content)
        tg_label <- glue("Section: {section_title}")
      }
      cli_progress_update()
      if (tg %in% c(
        "title", "description", "param", "seealso",
        "details", "returns", "format", "section", "return"
      )) {
        raw <- llm_vec_translate(raw, language = lang)
        if (tg == "section") {
          raw <- glue("{raw[1]}:\n{raw[2]}")
        }
        # raw <- gsub("\n", "\n#'", raw)
        if (tg != "title") {
          if (length(raw) != 0 && raw != "") {
            pre_raw <- paste0(tg, name, collapse = " ")
            raw <- glue("@{pre_raw} {raw}")
            raw <- split_paragraphs(raw, 65)
          }
        }
      } else {
        raw <- glue("@{tg} {raw}")
      }
      raw <- glue("#' {raw}")
      raw <- gsub("\n", "\n#' ", raw)
      contents <- c(contents, raw)
    }
    roxy_call <- roxy$call
    if (length(roxy_call) == 3) {
      args <- call_args(roxy_call[[3]])[[1]]
      
      str_args <- NULL
      for(i in seq_along(args)) {
        arg_val <- capture.output(args[[i]])
        arg_text <- names(args[i])
        if(arg_val != ""){
          arg_text <- paste(arg_text, "=", arg_val) 
        }
        str_args <- paste0(c(str_args, arg_text), collapse = ", ")
      }
      fn_str <- paste(
        as.character(roxy_call[[2]]), 
        as.character(roxy_call[[1]]), 
        str_args, 
        "{ NULL }"
        )
    } else {
      fn_str <- paste0("\"", as.character(roxy_call), "\"")
    }
    contents <- c(contents, fn_str)
  }
  if (!is.null(contents)) {
    writeLines(contents, rd_path)
  }
}
