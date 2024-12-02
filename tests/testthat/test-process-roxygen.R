test_that("Process roxygen works", {
  llm_use("simulate_llm", "echo", .silent = TRUE)  
  target <- tempdir()
  source <- test_path("test-pkg/R")
  expect_message(
    translate_roxygen(
      lang = "spanish", 
      folder = "es", 
      target = target,
      source = source
      )
    )
  expect_equal(
    c("data-reviews.R", "llm-classify.R", "llm-custom.R", "llm-extract.R", 
      "llm-sentiment.R", "llm-summarize.R", "llm-translate.R", "llm-use.R", 
      "llm-verify.R", "m-backend-prompt.R", "m-backend-submit.R", 
      "m-defaults.R",  "mall.R"
      ),
    path_file(dir_ls(path(target, "es")))
  )
})
