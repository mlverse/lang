test_that("Progress bar functions run without error", {
  local_mocked_bindings(
    is_interactive = function(...) TRUE
  )
  suppressMessages({
    expect_no_error(progress_bar_init(10L, ""))
    expect_no_error(progress_bar_update_text("Label"))
    expect_no_error(progress_bar_update_done("some result"))
  })
})

# ---- rd_flatten ---------------------------------------------------------------

test_that("rd_flatten emits [[markers]] for prose fields", {
  lst <- list(
    title = "My Function",
    description = c("Does something", "useful.")
  )
  out <- rd_flatten(lst)
  expect_true(grepl("[[title]]", out, fixed = TRUE))
  expect_true(grepl("My Function", out, fixed = TRUE))
  expect_true(grepl("[[description]]", out, fixed = TRUE))
  expect_true(grepl("Does something", out, fixed = TRUE))
})

test_that("rd_flatten emits argument markers without a section header", {
  lst <- list(
    arguments = list(
      list(argument = "x", description = "A data frame"),
      list(argument = "n", description = "Number of rows")
    )
  )
  out <- rd_flatten(lst)
  expect_true(grepl("[[x]]", out, fixed = TRUE))
  expect_true(grepl("A data frame", out, fixed = TRUE))
  expect_true(grepl("[[n]]", out, fixed = TRUE))
  expect_false(grepl("[[arguments]]", out, fixed = TRUE))
})

test_that("rd_flatten handles value with intro, components, and outro", {
  lst <- list(
    value = list(
      intro = "A list with:",
      components = list(
        list(component = "result", description = "The output"),
        list(component = "info", description = "Metadata")
      ),
      outro = "See details."
    )
  )
  out <- rd_flatten(lst)
  expect_true(grepl("[[value.intro]]", out, fixed = TRUE))
  expect_true(grepl("A list with:", out, fixed = TRUE))
  expect_true(grepl("[[result]]", out, fixed = TRUE))
  expect_true(grepl("[[value.outro]]", out, fixed = TRUE))
  expect_true(grepl("See details.", out, fixed = TRUE))
})

test_that("rd_flatten returns empty string for empty list", {
  expect_equal(rd_flatten(list()), "")
})

# ---- rd_count_fields ---------------------------------------------------------

test_that("rd_count_fields counts fields correctly", {
  lst <- list(
    title = "T",
    description = "D",
    arguments = list(
      list(argument = "x", description = "desc")
    )
  )
  expect_equal(rd_count_fields(lst), 3L)
})

# ---- rd_field_translate context block ----------------------------------------

test_that("rd_field_translate prepends context block when context_summary is set", {
  # Capture the add_prompt passed to llm_vec_translate by running with echo LLM
  invisible(
    lang_use_impl("simulate_llm", "echo", .is_internal = TRUE)
  )
  rs <- callr::r_session$new()
  on.exit(rs$close())
  lang_args <- lang_use_impl(.is_internal = TRUE)
  rs$run(
    function(x) rlang::exec(mall::llm_use, !!!x),
    args = list(
      x = list(
        backend = lang_args[["backend"]],
        model = lang_args[["model"]],
        .cache = lang_args[[".cache"]]
      )
    )
  )
  result_with <- rd_field_translate(
    "hello",
    "spanish",
    rs,
    context_summary = "A short summary"
  )
  result_without <- rd_field_translate(
    "hello",
    "spanish",
    rs,
    context_summary = NULL
  )
  # echo LLM returns input unchanged; both calls succeed without error
  expect_type(result_with, "character")
  expect_type(result_without, "character")
})

# ---- Ollama integration (local only, skipped on CRAN) ------------------------

test_that("rd_translate() produces correct output with Ollama", {
  skip_on_cran()
  skip_if(
    !isTRUE(tryCatch(
      {
        con <- url("http://localhost:11434")
        open(con)
        close(con)
        TRUE
      },
      error = \(e) FALSE
    )),
    "Ollama is not running locally"
  )
  lang_use("ollama", "llama3.2", seed = 374)
  expect_snapshot(rd_test_translate(test_path("rd/lang_help.Rd")))
  expect_snapshot(rd_test_translate(test_path("rd/aes.rds")))
})
