
<!-- README.md is generated from README.Rmd. Please edit that file -->

# lang

<!-- badges: start -->
<!-- badges: end -->

Using an LLM, **translate a function’s help documentation on-the-fly**.
`lang` “overrides” the `?` and `help()` functions in your R session.
This makes it very easy to run and access the translation. If you are
using RStudio or Positron, the resulting translated help page will
display in the usual help pane.

The language that the help documentation will be translated to, is
determined by one of the following two environment variables. In order
of priority, the variables are:

1.  `LANGUAGE`
2.  `LANG`

This package uses `mall` as the integration point with the LLM. Under
the hood, it runs `llm_vec_translate()` multiple times to translate the
most common sections of the help documentation (e.g.: Title,
Description, Details, Arguments, etc.).
