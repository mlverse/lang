test_that("Interaction with LLM works", {
  invisible(
    lang_use_impl("simulate_llm", "echo", temp = 0.8, .is_internal = TRUE)
  )
  expect_snapshot(
    lang_help("llm_classify", "mall", lang = "spanish", type = "text")
  )
  expect_error(
    lang_help("llm_classify", "mall", lang = "english", type = "text")
  )
  expect_snapshot_error(
    lang_help("nothere", lang = "spanish", type = "text")
  )
  expect_snapshot_error(
    lang_help("nothere", "notpkg", lang = "spanish", type = "text")
  )
  expect_snapshot_error(
    lang_help("nothere", "mall", lang = "spanish", type = "text")
  )
  skip_on_os("windows")
  expect_silent(
    lang_help("lm", lang = "spanish", type = "text")
  )
})
