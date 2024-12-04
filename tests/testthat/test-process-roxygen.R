skip_on_os("windows")

test_that("Process Roxygen works", {
  temp_path <- withr::local_tempdir(.local_envir = caller_env())
  pkg_name <- "test-pkg"
  dir_copy(test_path(pkg_name), temp_path)
  local_pkg <- path(temp_path, pkg_name)
  print(dir_ls(local_pkg))
  expect_message(
    process_roxygen(pkg_path = local_pkg)
  )
  lang_folder <- path(local_pkg, "inst", "man-lang", "es")
  expect_snapshot_file(path(lang_folder, "llm_classify.Rd"))
  expect_snapshot_file(path(lang_folder, "reviews.Rd"))
})
