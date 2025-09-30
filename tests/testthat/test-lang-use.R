test_that("Empty lang_use() returns 'unset'", {
  .lang_env$session <- NULL
  expect_snapshot(
    lang_use()
  )
})

test_that("lang_use() works", {
  expect_snapshot(
    lang_use("simulate_llm", "echo", .cache = "path/to/cache", .lang = "test")
  )
})

test_that("lang_use() works with ellmer", {
  x <- simulate_ellmer()
  expect_snapshot(
    lang_use(x, .cache = "path/to/cache", .lang = "test")
  )
})

test_that("lang_use() works with additional arguments", {
  expect_snapshot(
    lang_use("simulate_llm", "echo", temp = 0.8, .cache = "path/to/cache", .lang = "test")
  )
})

test_that("lang_use() works with disabled cache", {
  expect_snapshot(
    lang_use("simulate_llm", "echo", .cache = "", .lang = "test")
  )
})

test_that("Warning is displayed if .lang_chat is set", {
  withr::with_options(
    list(.lang_chat = 3),
    expect_warning(lang_use())
  )
})
