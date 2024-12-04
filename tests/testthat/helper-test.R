local_package_copy <- function(path, env = caller_env(), set_version = TRUE) {
  temp_path <- withr::local_tempdir(.local_envir = env)
  
  file.copy(path, temp_path, recursive = TRUE)
  pkg_path <- dir(temp_path, full.names = TRUE)[[1]]
  
  if (set_version) {
    desc::desc_set(
      file = pkg_path,
      RoxygenNote = as.character(packageVersion("roxygen2"))
    )
  }
  
  normalizePath(pkg_path, winslash = "/")
}
