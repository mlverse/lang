process_roxygen <- function(lang, source = "man-lang", target = "inst/man-lang") {
  temp_dir <- tempfile()
  dir_create(temp_dir)
  pkg_dir <- path_abs(".")
  pkg_name <- path_file(pkg_dir)
  dir_copy(pkg_dir, temp_dir)
  copy_path <- path(temp_dir, pkg_name)
  dir_delete(path(copy_path, "man"))
  file_copy(
    path = dir_ls(path(copy_path, source, lang)), 
    new_path = path(copy_path, "R"),
    overwrite = TRUE
    )
  roxygen2::roxygenize(copy_path, roclets = "rd")
  target_path <- path(target, lang)
  dir_create(target_path)
  file_copy(
    path = dir_ls(path(copy_path, "man")),
    new_path = target_path, 
    overwrite = TRUE
    )
  dir_delete(temp_dir)  
}
