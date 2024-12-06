#' Creates the Rd files based on translated Roxygen scripts
#' @param folder Source sub-folder where the source Roxygen R scripts are
#' @param source_folder Base source folder where the different translations are located.
#' Defaults to 'man-lang'.
#' @param target_folder Base target folder where the different translations will be
#' located. Defaults to 'inst/man-lang'
#' @param r_folder Source of the original R scripts. Only used to see if the 
#' Roxygen documentation is different from what is capture in the `source_folder`
#' @param pkg_path The path to the package
#' @returns Multiple Rd files based on the source R scripts
#' @export
process_roxygen_folder <- function(
    folder,
    r_folder = "R", 
    source_folder = "man-lang",
    target_folder = "inst/man-lang",
    pkg_path = ".") {
  
  pkg_dir <- path_abs(pkg_path)
  r_scripts <- dir_ls(path(pkg_dir, r_folder), glob = "*.R")
  r_comments <- lapply(r_scripts, roxy_comments)
  full_source <- dir_ls(path(pkg_path, source_folder, folder))
  man_comments <- lapply(full_source, roxy_existing)
  
  
  # Create temporary directory
  temp_dir <- tempfile()
  dir_create(temp_dir)
  # Copies root contents to temp directory
  
  pkg_name <- path_file(pkg_dir)
  dir_copy(pkg_dir, temp_dir)
  copy_path <- path(temp_dir, pkg_name)
  # Removes current content in 'man' of the temp copy of
  # the package
  man_path <- path(copy_path, "man")
  if (dir_exists(man_path)) {
    dir_delete(path(copy_path, "man"))
  }
  # Copies content of the translated script to the R folder
  # of the temp copy
  file_copy(
    path = full_source,
    new_path = path(copy_path, "R"),
    overwrite = TRUE
  )
  # Uses `callr` to run roxygenize, mainly to avoid the messages from roxygen2
  cli_h3("Creating Rd files for '{folder}'")
  callr::r_safe(
    func = function(x) roxygen2::roxygenize(x, roclets = "rd"),
    args = list(copy_path)
  )
  # Copies the new contents in 'man' from the temp copy
  # into target folder, under the language's sub-folder
  target_path <- path(pkg_path, target_folder, folder)
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
process_roxygen <- function(
    source_folder = "man-lang",
    target_folder = "inst/man-lang",
    pkg_path = ".") {
  sub_folders <- dir_ls(path(pkg_path, source_folder), type = "directory")
  for (folder in sub_folders) {
    process_roxygen_folder(
      folder = path_file(folder),
      source_folder = source_folder,
      target_folder = target_folder,
      pkg_path = pkg_path
    )
  }
}
