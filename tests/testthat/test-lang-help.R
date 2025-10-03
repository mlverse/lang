test_that("Interaction with LLM works", {
  x <- lang_use_impl("simulate_llm", "echo", .is_internal = TRUE)
  expect_snapshot(
    lang_help("llm_classify", "mall", lang = "spanish", type = "text")
  )
  expect_error(
    lang_help("llm_classify", "mall", lang = "english", type = "text")
  )
  expect_silent(lang_help("lm", lang = "spanish", type = "text"))
})
