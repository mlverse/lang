test_that("shim_lang_help works", {
  expect_snapshot(
    withr::with_envvar(c("LANG" = "spanish"), {
      x <- lang_use_impl("simulate_llm", "echo", .is_internal = TRUE)
      shim_lang_help("llm_classify", "mall", type = "text")
    })
  )
})

test_that("shim_lang_question works", {
  expect_snapshot(
    withr::with_options(
      list(help_type = "text"),
      {
        withr::with_envvar(c("LANG" = "spanish"), {
          x <- lang_use_impl("simulate_llm", "echo", .is_internal = TRUE)
          shim_lang_question("llm_classify", "mall")
        })
      }
    )
  )
})

test_that("Shim is able to be attached", {
  insert_global_shims(force = TRUE)
  shims <- find("?")
  expect_true("lang_shims" %in% shims)

  expect_snapshot(
    withr::with_options(
      list(help_type = "text"),
      {
        withr::with_envvar(c("LANG" = "spanish"), {
          x <- lang_use_impl("simulate_llm", "echo", .is_internal = TRUE)
          help(llm_classify)
        })
      }
    )
  )  
})

test_that("end_lang() works", {
  expect_true(en_lang("en_"))
})
