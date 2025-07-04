test_that("From ISO works", {
  expect_equal(from_iso639("en"), "english")
  expect_null(from_iso639("xx"))
})

test_that("To ISO works", {
  expect_equal(to_iso639("english"), "en")
  expect_message(to_iso639("english", silent = FALSE))
  expect_error(to_iso639("not.valid", silent = FALSE))
})
