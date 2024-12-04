test_that("Translate Roxygen works", {
  llm_use("simulate_llm", "echo", .silent = TRUE)
  temp_pkg <- path(tempdir(), "test-pkg")
  dir_copy(test_path("test-pkg"), temp_pkg)
  expect_message(
    translate_roxygen(
      lang = "spanish",
      folder = "es",
      target = path(temp_pkg, "man-lang"),
      source = path(temp_pkg, "R")
    )
  )
  expect_equal(
    c(
      "data-reviews.R", "llm-classify.R", "llm-custom.R", "llm-extract.R",
      "llm-sentiment.R", "llm-summarize.R", "llm-translate.R", "llm-use.R",
      "llm-verify.R", "m-backend-prompt.R", "m-backend-submit.R",
      "m-defaults.R", "mall.R"
    ),
    path_file(dir_ls(path(temp_pkg, "man-lang", "es")))
  )
})
