#' Translates the Roxygen2 documentation to a different language
#' @description
#' Reads the Roxygen2 tags in the package and translates them. The translations
#' are stored in R scripts. The default location of the new scripts is 'man-lang'.
#' They will be in a sub-folder representing the language the are translated to.
#'
#' @details This approach makes it easier to edit the translations by hand after
#' the LLM does a first pass. It also allows for others to collaborate
#' with improving the translation.
#' @param lang The target language to translate help to
#' @param lang_sub_folder 2-letter language/source folder to save the new
#' Roxygen scripts to.
#' @param lang_folder The target base folder to save the Roxygen files. It defaults
#' to 'man-lang'. The final destination will be a combination of this and the
#' folder from `folder`
#' @param r_script A single R script to translate. Defaults to NULL. If it is
#' null, then every R script in the `r_folder` will be translated
#' @param r_folder The source R scripts. It defaults to the 'R' folder.
#'
#' @export
translate_roxygen <- function(
    lang,
    lang_sub_folder,
    lang_folder = path("man-lang"),
    r_script = NULL,
    r_folder = path("R")) {
  if (nchar(lang_sub_folder) != 2) {
    cli_abort("Use an ISO 639 2 character language code for `folder`")
  }
  if (!is_dir(r_folder)) {
    cli_abort("`source` needs to be a valid directory")
  }
  lang_folder <- path(lang_folder, lang_sub_folder)
  dir_create(lang_folder)
  if (is.null(r_script)) {
    cli_h3("`lang` translating Roxygen into '{lang}'")
    r_script <- dir_ls(r_folder, glob = "*.R")
  }
  pkg_env <- env_package(r_folder)
  for (i in seq_along(r_script)) {
    translate_roxygen_imp(
      path = r_script[[i]],
      lang = lang,
      dir = lang_folder,
      no = i,
      of = length(r_script),
      pkg_env = pkg_env
    )
  }
}

translate_roxygen_imp <- function(path,
                                  lang = NULL,
                                  dir,
                                  no = 1,
                                  of = 1,
                                  pkg_env = NULL) {
  current_roxy <- roxy_comments(path)
  result_msg <- ""
  if (is.null(current_roxy)) {
    result_msg <- "[Skipping, no Roxygen content found]"
  }
  dir_create(dir)
  rd_path <- path(dir, path_file(path))
  if (file_exists(rd_path)) {
    tr_roxy <- roxy_existing(rd_path)
    tr_string <- paste0(tr_roxy, collapse = " ")
    cr_string <- paste0(current_roxy, collapse = " ")
    if (tr_string == cr_string) {
      result_msg <- "[Skipping, no changes detected]"
    }
  }
  if (result_msg == "") {
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
      roxy_call <- capture.output(roxy$call)
      fn_str <- paste0(roxy_call, collapse = "")
      if (grepl("[{]", fn_str) && grepl("[}]", fn_str)) {
        fn_str <- unlist(strsplit(fn_str, "[{]"))[[1]]
        fn_str <- paste0(fn_str, "{ NULL }")
      }
      contents <- c(contents, fn_str)
    }
    if (!is.null(contents)) {
      result_msg <- rd_path
      contents <- c(
        contents,
        "# --- Created by `lang` do not edit by hand ---",
        current_roxy
      )
      writeLines(contents, rd_path)
    }
  }
  cli_inform("[{no}/{of}] {path} --> {result_msg}")
  invisible()
}

roxy_comments <- function(x) {
  script_contents <- readLines(x)
  roxy_comment <- substr(script_contents, 1, 2) == "#'"
  just_roxy <- script_contents[roxy_comment]
  just_roxy <- just_roxy[just_roxy != "#'"]

  if (length(just_roxy) == 0) {
    return(NULL)
  } else {
    just_roxy <- paste0("#-", just_roxy)
    no_exports <- !any(grepl("#' @export", just_roxy))
    no_name <- !any(grepl("#' @name", just_roxy))
    if (no_exports && no_name) {
      return(NULL)
    }
  }
  just_roxy
}

roxy_existing <- function(x) {
  script_contents <- readLines(x)
  roxy_comment <- substr(script_contents, 1, 4) == "#-#'"
  script_contents[roxy_comment]
}
