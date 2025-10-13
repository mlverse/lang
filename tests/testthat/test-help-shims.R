skip_on_os("windows")

test_that("shim_lang_help works", {
  invisible(
    lang_use_impl("simulate_llm", "echo", .is_internal = TRUE, .lang = "spanish")
  )
  expect_silent(shim_lang_help(NULL))
  expect_silent(shim_lang_help(NULL, base))
  expect_silent(shim_lang_help(NULL, "base"))
  expect_silent(shim_lang_help("NULL", base))
  expect_silent(shim_lang_help("NULL", "base"))
  expect_silent(shim_lang_help(mtcars))
  expect_silent(shim_lang_help("mtcars"))
  expect_silent(shim_lang_help(mtcars, datasets))
  expect_silent(shim_lang_help("mtcars", "datasets"))
  invisible(
    lang_use_impl("simulate_llm", "echo", .is_internal = TRUE, .lang = "english")
  )
  expect_silent(shim_lang_help(mtcars))
})

test_that("Shim is able to be attached", {
  insert_global_shims(force = TRUE)
  shims <- find("?")
  expect_true("lang_shims" %in% shims)
  expect_null(insert_global_shims())
})

test_that("en_lang() works", {
  expect_true(en_lang("en_"))
})

test_that("Conflicting language message shows up", {
  withr::with_envvar(c(LANGUAGE = "spanish", LANG = "english"), {
    x <- lang_use_impl("simulate_llm", "echo", .is_internal = TRUE)
    .lang_env$choose <- NULL
    .lang_env[["session"]]$.lang <- NULL
    expect_snapshot(which_lang(choose = TRUE))
  })
})

test_that("No vars and arg returns 'english'", {
  withr::with_envvar(c(LANGUAGE = NA, LANG = NA), {
    x <- lang_use_impl("simulate_llm", "echo", .is_internal = TRUE)
    .lang_env$choose <- NULL
    .lang_env[["session"]]$.lang <- NULL
    expect_equal(which_lang(), "english")
  })
})

test_that("shim_lang_question works", {
  withr::with_options(
    list(help_type = "text"),
    {
      invisible(
        lang_use_impl("simulate_llm", "echo", .is_internal = TRUE, .lang = "spanish")
      )
      expect_silent(shim_lang_question(lm))
      expect_silent(shim_lang_question(datasets::mtcars))
      expect_silent(shim_lang_question(mtcars()))
      expect_silent(shim_lang_question("mtcars"))
      expect_silent(shim_lang_question("mtcars", "stats"))
      expect_error(shim_lang_question(1), "Unknown input")
      expect_silent(shim_lang_question(NULL))
      expect_silent(shim_lang_question(base::`NULL`))
      expect_identical(
        shim_lang_question(?mtcars),
        utils::`?`(?mtcars)
      )
    }
  )
})
