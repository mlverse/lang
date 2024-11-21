#' Creates the Rd files based on translated Roxygen scripts
#' @param lang 2-letter language/source folder where the translated Roxygen
#' scripts are located
#' @param source Root source folder where the different translations are located.
#' Defaults to 'man-lang'.
#' @param target Root target folder where the different translations will be
#' located. Defaults to 'inst/man-lang'
#' @returns Multiple Rd files based on the source R scripts
#' @export
process_roxygen <- function(lang, source = "man-lang", target = "inst/man-lang") {
  if (nchar(lang) != 2) {
    cli_abort("Use an ISO 639 2 character language code for `lang`")
  }  
  # Create temporary directory
  temp_dir <- tempfile()
  dir_create(temp_dir)
  # Copies root contents to temp directory
  pkg_dir <- path_abs(".")
  pkg_name <- path_file(pkg_dir)
  dir_copy(pkg_dir, temp_dir)
  copy_path <- path(temp_dir, pkg_name)
  # Removes current content in 'man' of the temp copy of 
  # the package
  dir_delete(path(copy_path, "man"))
  # Copies content of the translated script to the R folder 
  # of the temp copy
  file_copy(
    path = dir_ls(path(copy_path, source, lang)),
    new_path = path(copy_path, "R"),
    overwrite = TRUE
  )
  # Runs documentation function against the temp copy
  roxygen2::roxygenize(copy_path, roclets = "rd")
  # Copies the new contents in 'man' from the temp copy 
  # into target folder, under the language's subfolder
  target_path <- path(target, lang)
  dir_create(target_path)
  file_copy(
    path = dir_ls(path(copy_path, "man")),
    new_path = target_path,
    overwrite = TRUE
  )
  # Deletes the temporary folder
  dir_delete(temp_dir)
}
