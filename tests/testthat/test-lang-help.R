test_that("Interaction with LLM works", {
  llm_use("simulate_llm", "echo", .silent = TRUE)
  expect_snapshot(
    lang_help("llm_classify", "mall", lang = "spanish", type = "text")
  )
})
