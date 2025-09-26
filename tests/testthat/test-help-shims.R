skip_on_os("windows")

test_that("shim_lang_help works", {
  withr::with_envvar(c("LANGUAGE" = "spanish", LANG = NA), {
    x <- lang_use_impl("simulate_llm", "echo", .is_internal = TRUE)
    expect_snapshot(shim_lang_help("llm_classify", "mall", type = "text"))
  })
})

test_that("shim_lang_question works", {
  withr::with_options(
    list(help_type = "text"),
    {
      withr::with_envvar(c("LANGUAGE" = "en", LANG = NA), {
        x <- lang_use_impl("simulate_llm", "echo", .is_internal = TRUE)
        expect_snapshot(shim_lang_question("llm_classify", "mall"))
      })
    }
  )
})

test_that("Shim works as expected", {
  expect_snapshot(
    withr::with_options(
      list(help_type = "text"),
      {
        x <- lang_use_impl("simulate_llm", "echo", .is_internal = TRUE)
        shim_lang_question(mall::llm_classify)
      }
    )
  )
})

test_that("Shim works as expected", {
  withr::with_options(
    list(help_type = "text"),
    {
      x <- lang_use_impl("simulate_llm", "echo", .is_internal = TRUE)
      expect_identical(
        shim_lang_question(?lm),
        utils::`?`(?lm)
      )
    }
  )
})

test_that("Shim is able to be attached", {
  insert_global_shims(force = TRUE)
  shims <- find("?")
  expect_true("lang_shims" %in% shims)
  withr::with_options(
    list(help_type = "text"),
    {
      withr::with_envvar(c("LANGUAGE" = "spanish", LANG = NA), {
        x <- lang_use_impl("simulate_llm", "echo", .is_internal = TRUE)
        expect_snapshot(help(llm_classify))
        expect_snapshot(shim_lang_question(llm_classify))
      })
    }
  )
})

test_that("end_lang() works", {
  expect_true(en_lang("en_"))
})

test_that("Conflicting language message shows up", {
  withr::with_envvar(c("LANGUAGE" = "spanish", LANG = "english"), {
    x <- lang_use_impl("simulate_llm", "echo", .is_internal = TRUE)
    expect_snapshot(which_lang(choose = TRUE))
  })
})
