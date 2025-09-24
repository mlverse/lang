test_that("lang_use() works", {
  expect_snapshot(
    lang_use("simulate_llm", "echo", .cache = "path/to/cache")
  )
})

test_that("lang_use() works with ellmer", {
  x <- simulate_ellmer()
  expect_snapshot(
    lang_use(x, .cache = "path/to/cache")
  )
})

test_that("lang_use() works with additional arguments", {
  expect_snapshot(
    lang_use("simulate_llm", "echo", temp = 0.8, .cache = "path/to/cache")
  )
})

test_that("lang_use() works with disabled cache", {
  expect_snapshot(
    lang_use("simulate_llm", "echo", .cache = "")
  )
})
