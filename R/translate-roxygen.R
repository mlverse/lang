#' Translates the Roxygen2 documentation
#' @description
#' Reads the Roxygen2 tags in the package and translates them. The translations
#' are stored in R scripts. The default location of the new scripts is 'man-lang'.
#' The will be in a sub-folder representing the language the are translated to.
#'
#' @details This approach makes it easier to edit the translations by hand after
#' the LLM does a first pass. This way it is easier for others to collaborate
#' with improving the translation
#' @param lang The target language to translate help to
#' @param target_subfolder 2-letter language/source folder to save the new
#' Roxygen scripts to
#' @param target The target base folder to save the Roxygen files. It defaults
#' to 'man-lang'. The final destination will be a combination of this and the
#' folder from `target_subfolder`
#' @param source The source R scripts. It defaults to the 'R' folder.
#'
#' @export
translate_roxygen <- function(
    lang,
    target_subfolder,
    target = path("man-lang"),
    source = path("R")) {
  if (nchar(target_subfolder) != 2) {
    cli_abort("Use an ISO 639 2 character language code for `target_subfolder`")
  }
  target <- path(target, target_subfolder)
  dir_create(target)
  if (is_dir(source)) {
    cli_h3("`lang` translating Roxygen into '{lang}'")
    r_files <- dir_ls(source, glob = "*.R")
    pkg_env <- env_package(path_file(source))
    for (i in seq_along(r_files)) {
      translate_roxygen_file(
        path = r_files[[i]],
        lang = lang,
        dir = target,
        no = i,
        of = length(r_files),
        pkg_env = pkg_env
      )
    }
  } else {
    cli_abort("`source` needs to be a valid directory")
  }
}

translate_roxygen_file <- function(path,
                                   lang = NULL,
                                   dir,
                                   no = 1,
                                   of = 1,
                                   pkg_env = NULL) {
  if (is.null(pkg_env)) {
    if(is_dir(path)) {
      pkg_path <- path_dir(path)
    } else {
      pkg_path <- path_dir(path_dir(path))
    }
    pkg_env <- env_package(pkg_path)
  }
  rd_path <- path(dir, path_file(path))
  cli_inform("[{no}/{of}] {path} --> {rd_path}")
  parsed <- parse_file(path, env = pkg_env)
  contents <- NULL
  for (roxy in parsed) {
    tg <- NULL
    cli_progress_message("Translating: {.emph {tg}}")
    for (tag in roxy$tags) {
      tg <- tag$tag
      raw <- tag$raw
      if (tg %in% c(
        "title", "description", "param","seealso", 
        "details", "returns", "format", "section", "return"
      )
      ) {
        cli_progress_update()
        raw <- llm_vec_translate(raw, language = lang)
      }
      if (tg == "param") {
        name <- glue(" {tag$val$name} ")
      } else {
        name <- ""
      }
      raw <- gsub("\n", "\n#'", raw)
      if (tg == "title") {
        contents <- c(contents, glue("#' {raw}"))
      } else {
        contents <- c(contents, glue("#' @{tg} {name} {raw}"))
      }
    }
    contents <- c(contents, glue("{roxy$object$alias} <- function(...) NULL"))
  }
  if (!is.null(contents)) {
    writeLines(contents, rd_path)
  }
}
