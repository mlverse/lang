# These tests run first (aaa) to verify behavior before any lang_use() setup.

test_that("lang_help() errors clearly when no backend is configured", {
  expect_snapshot(
    error = TRUE,
    lang_help("lm", "stats", lang = "spanish")
  )
})
