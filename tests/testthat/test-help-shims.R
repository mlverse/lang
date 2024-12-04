test_that("shim_lang_help works", {
  expect_snapshot(
    withr::with_envvar(c("LANG" = "spanish"), {
      llm_use("simulate_llm", "echo", .silent = TRUE)
      shim_lang_help("llm_classify", "mall", type = "text")
    })
  )
})

test_that("shim_lang_question works", {
  expect_snapshot(
    withr::with_options(
      list(help_type = "text"),
      {
        withr::with_envvar(c("LANG" = "spanish"), {
          llm_use("simulate_llm", "echo", .silent = TRUE)
          shim_lang_question("llm_classify", "mall")
        })
      }
    )
  )
})
