#' Creates the Rd files based on translated Roxygen scripts
#' @param folder Source sub-folder where the source Roxygen R scripts are
#' @param source Base source folder where the different translations are located.
#' Defaults to 'man-lang'.
#' @param target Base target folder where the different translations will be
#' located. Defaults to 'inst/man-lang'
#' @returns Multiple Rd files based on the source R scripts
#' @export
process_roxygen_folder <- function(folder, source = "man-lang", target = "inst/man-lang") {
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
    path = dir_ls(path(copy_path, source, folder)),
    new_path = path(copy_path, "R"),
    overwrite = TRUE
  )
  # Using callr to avoid the messages from roxygen2
  cli_h3("Creating Rd files for '{folder}'")
  callr::r(
    func = function(x) roxygen2::roxygenize(x, roclets = "rd"),
    args = list(copy_path)
  )
  # Copies the new contents in 'man' from the temp copy
  # into target folder, under the language's sub-folder
  target_path <- path(target, folder)
  if (dir_exists(target_path)) {
    dir_delete(target_path)
  }
  dir_create(target_path)
  file_copy(
    path = dir_ls(path(copy_path, "man")),
    new_path = target_path,
    overwrite = TRUE
  )
  for (files in dir_ls(target_path)) {
    cli_inform(" - {path(files)}")
  }
  # Deletes the temporary folder
  dir_delete(temp_dir)
  invisible()
}

#' @rdname process_roxygen_folder
#' @export
process_roxygen <- function(source = "man-lang", target = "inst/man-lang") {
  sub_folders <- dir_ls(source, type = "directory")
  for (folder in sub_folders) {
    process_roxygen_folder(path_file(folder), source, target)
  }
}
