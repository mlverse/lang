# ---- Ollama integration (local only, skipped on CRAN) ------------------------
# These tests run last to avoid interfering with simulate_llm state in other tests.

test_that("rd_translate() produces correct output with Ollama", {
  skip_on_cran()
  skip_if(
    !isTRUE(tryCatch(
      {
        con <- url("http://localhost:11434")
        suppressWarnings(open(con))
        close(con)
        TRUE
      },
      error = \(e) FALSE,
      warning = \(e) FALSE
    )),
    "Ollama is not running locally"
  )
  lang_use_impl(
    "ollama",
    "llama3.2",
    seed = 374,
    temp = NULL,
    .is_internal = TRUE
  )
  expect_snapshot(rd_test_translate(test_path("rd/lang_help.Rd")))
  expect_snapshot(rd_test_translate(test_path("rd/aes.rds")))
})
