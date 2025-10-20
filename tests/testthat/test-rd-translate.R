test_that("Progress messages work", {
  local_mocked_bindings(
    is_interactive = function(...) TRUE
  )
  new_obj <- list(1:1000)
  expect_silent(progress_bar_init(object.size(new_obj), ""))
  expect_silent(progress_bar_update(10))
  expect_silent(progress_bar_update(obj = list(1:10)))
  expect_silent(progress_bar_update(obj = new_obj))
})
