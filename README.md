
<!-- README.md is generated from README.Rmd. Please edit that file -->

# lang

<!-- badges: start -->

[![R-CMD-check](https://github.com/mlverse/lang/actions/workflows/R-CMD-check.yaml/badge.svg)](https://github.com/mlverse/lang/actions/workflows/R-CMD-check.yaml)
[![Codecov test
coverage](https://codecov.io/gh/mlverse/lang/branch/main/graph/badge.svg)](https://app.codecov.io/gh/mlverse/lang?branch=main)
<!-- badges: end -->

Use an **LLM to translate a function’s help documentation on-the-fly**.
`lang` overrides the `?` and `help()` functions in your R session. If
you are using RStudio or Positron, the translated help page will appear
in the usual help pane.

If you are a package developer, `lang` helps you translate your
documentation, and to include it as part of your package. `lang` will
use the same `?` override to display your translated help documents.

## Installation

To install the GitHub version of `lang`, use:

``` r
install.packages("pak")
pak::pak("mlverse/lang")
```

## Using `lang`

If you have not used `mall` yet, then the first step is to set it up.
Feel free to follow the instructions in that package’s [Get
Started](https://mlverse.github.io/mall/#get-started) page. Setting up
your LLM and `mall` should be a one time process.

On an every day R session, you’ll just need to load `lang` and then tell
it which model to run using `llm_use()`:

``` r
library(lang)

llm_use("ollama", "llama3.2", seed = 100)
```

After that, simply use `?` to trigger and display the translated
documentation. During translation, `lang` will display its progress by
showing which section of the documentation is currently translating:

``` r
> ?lm
Translating: Title
```

If your environment is set to use the Spanish language, the help pane
should display this:

<img src="man/figures/lm-spanish.png" align="center" 
alt="Screenshot of the lm function's help page in Spanish"/>

R enforces the printed name of each section, so they cannot be
translated. So titles such as Description, Usage and Arguments will
always remain untranslated.

### How it works

The language that the help documentation will be translated to, is
determined by one of the following two environment variables. In order
of priority, the variables are:

1.  `LANGUAGE`
2.  `LANG`

It is likely that your `LANG` variable already defaults to your locale.
For example, mine is set to: `en_US.UTF-8` (That means English, United
States). For someone in France, the locale would be something such as
`fr_FR.UTF-8`. Llama3.2, recognizes these UTF locales, and using `lang`,
calling `?` will result in translating the function’s help documentation
into French.

It uses the `mall` package as the integration point with the LLM. Under
the hood, it runs `llm_vec_translate()` multiple times to translate the
most common sections of the help documentation (e.g.: Title,
Description, Details, Arguments, etc.). If `lang` determines that your
environment is set to use English, it will simply display the original
documentation.

### Considerations

#### Translation is not perfect

As you can imagine, the quality of translation will mostly depend on the
LLM being used. This solution is meant to be as helpful as possible, but
acknowledging that at this stage of LLMs, only a human curated
translation will be the best solution. Having said that, I believe that
even an imperfect translation could go a long way with someone who is
struggling to understand how to use a specific function in a package,
and may also struggle with the English language.

#### Debug

If the original English help page displays, check your environment
variables:

``` r
Sys.getenv("LANG")
#> [1] "en_US.UTF-8"
Sys.getenv("LANGUAGE")
#> [1] ""
```

In my case, `lang` recognizes that the environment is set to English,
because of the `en` code in the variable. If your `LANG` variable is set
to `en_...` then no translation will occur.

If this is your case, set the `LANGUAGE` variable to your preference.
You can use the full language name, such as ‘spanish’, or ‘french’, etc.
You can use `Sys.setenv(LANGUAGE = "[my language]")`, or, for a more
permanent solution, add the entry to your your .Renviron file
(`usethis::edit_r_environ()`).

## Package Developers

You may want to provide translations of your documentation as part of
your package.`lang` includes an entire infrastructure to help you to do
the following:

- Let the LLM take the first pass at translating your documentation
- Easily edit the translations. This means, either you, or a
  collaborator, can fine tune the new files
- Include the translated Rd files as part of your package
- Have `?` and `help()` pull from your translated documents

### LLM First pass

While inside your package’s project, use `translate_roxygen()` to have
`lang` translate all of your documentation to the desired language. The
function call must include the target language, and the sub-folder to
save the translated files to:

``` r
translate_roxygen("spanish", "es")
```

That function call will iterate through your **‘R/’** folder and
translate all of your
[`roxygen2`](https://roxygen2.r-lib.org/index.html) documentation. The
new Roxygen documents will be saved, by default, to a new
**‘man-lang/’** folder. Make sure to add the new folder to your project
**‘.Rbuildignore’** file (`^man-lang$`)

**ISO 639 codes** - The name of the sub-folder to use needs to be the
two letter designation of the target language you are using. That is why
we used **es** for Spanish. For the list of codes, you can refer to the
[Wikipedia page
here](https://en.wikipedia.org/wiki/List_of_ISO_639_language_codes). If
you do not pass the `lang_sub_folder` argument, then `lang` will use the
`to_iso639()` function to automatically convert the value of `lang` to a
valide 2-character language code:

For this package, making that function call creates this console output:

``` r
> translate_roxygen("spanish")
✔ 'spanish' converted to ISO 639 code: 'es'
ℹ Loading lang
[1/9] R/help-shims.R --> man-lang/es/help-shims.R
[2/9] R/iso-639.R --> man-lang/es/iso-639.R
[3/9] R/lang-help.R --> man-lang/es/lang-help.R
[4/9] R/lang.R --> [Skipping, no Roxygen content found]
[5/9] R/mall-reexports.R --> man-lang/es/mall-reexports.R
[6/9] R/process-roxygen.R --> man-lang/es/process-roxygen.R
[7/9] R/roxy-comments.R --> [Skipping, no Roxygen content found]
[8/9] R/translate-roxygen.R --> man-lang/es/translate-roxygen.R
[9/9] R/utils.R --> [Skipping, no Roxygen content found]
```

`lang` ties the resulting translated R scripts to the source R scripts
by adding a copy of the original Roxygen documentation. This way, it
avoids re-translating the content if nothing has changed:

``` r
> translate_roxygen("spanish")
✔ 'spanish' converted to ISO 639 code: 'es'
ℹ Loading lang
[1/9] R/help-shims.R --> [Skipping, no changes detected]
[2/9] R/iso-639.R --> [Skipping, no changes detected]
[3/9] R/lang-help.R --> [Skipping, no changes detected]
[4/9] R/lang.R --> [Skipping, no Roxygen content found]
[5/9] R/mall-reexports.R --> [Skipping, no changes detected]
[6/9] R/process-roxygen.R --> [Skipping, no changes detected]
[7/9] R/roxy-comments.R --> [Skipping, no Roxygen content found]
[8/9] R/translate-roxygen.R --> [Skipping, no changes detected]
[9/9] R/utils.R --> [Skipping, no Roxygen content found]
```

### Edit the translations

As mentioned in the previous section, `lang` translates the functions’
Roxygen comments. This approach allows you as the developer to easily
edit the output.

For the `lang_help()` function, in the **‘R/lang-help.R’** script, the
top of the documentation looks like this:

``` r
#' Translates help
#' @description
#' Translates a given topic into a target language. It uses the `lang` argument
#' to determine which language to translate to. If not passed, this function will
#' look for a target language in the LANG and LANGUAGE environment variables to
#' determine the target language. If the target language is English, no translation
#' will be processed, so the help returned will be the original package's
#' documentation.
#'
#' @param topic The topic to search for
#' @param package The R package to look for the topic
#' @param lang Language to translate the help to
#' @param type Produce "html" or "text" output for the help. It default to
#' `getOption("help_type")`
...
```

And this is what the translation in **‘man-lang/es/lang.R’** looks like:

``` r
#' Ayuda en traducción
#' @description La función traduce un tema dado a un idioma objetivo. Utiliza
#' el argumento `lang` para determinar qué idioma traducir. Si no se pasa, esta
#' función busca un idioma objetivo en las variables de entorno LANG y LANGUAGE
#' para determinarlo. Si el idioma objetivo es inglés, no se procesa la
#' traducción, por lo que se devuelve la documentación original del paquete.
#' @param topic  El tema de búsqueda principal.
#' @param package  Paquete R para buscar el tema.
#' @param lang  Please provide the text you'd like me to translate.
#' @param type  Utilice "html" o "texto" como salida para la ayuda, de lo
#' contrario se utilizará el valor por defecto de `getOption("help_type")`.
...
```

Editing an R scripts Roxygen comments is a lot easier than editing an Rd
file, additionally, this solution integrates better with the usual
package development process.

It also opens the possibility to have collaborators to submit PRs to
your package’s repository with edits to the translation, or even submit
brand new translations.

### Include translations in your package

The Rd help files are still the best way for R to process and display
your help files. The second, and final step, will be to have `lang`
create the Rd files based on the translated Roxygen comments, simply
run:

``` r
process_roxygen()
```

That function will iterate through all the language sub-folders in
**‘man-lang/’** to process the Rd files. The resulting Rd files will be
saved to **‘inst/man-lang/’**. Please keep in mind that this step does
not need an LLM to work. It is only creating the Rd files, and putting
them in the correct location.

Under the hood, `lang` creates temporary copies of your package,
replaces the scripts in the ‘R’ folder with your translations, and then
runs the `roxygen2::roxygenize()` function. This ensures that the Rd
creation is as close as possible as if you were running
`devtools::document()` during your package development.

For this package, making that function call creates this console output:

``` r
> process_roxygen()
ℹ Creating Rd files from man-lang/es (Spanish)
- ./inst/man-lang/es/help.Rd
- ./inst/man-lang/es/lang_help.Rd
- ./inst/man-lang/es/process_roxygen.Rd
- ./inst/man-lang/es/reexports.Rd
- ./inst/man-lang/es/to_iso639.Rd
- ./inst/man-lang/es/translate_roxygen.Rd
```

As an additional aid, `lang` will compare the Roxygen documentation in
your current **‘R/’** folder, with the copy of the documentation made at
the time of translation. If there are differences, `lang` will show you
a warning indicating that a given translation may be out of date:

``` r
> process_roxygen()
! The following R documentation has changed, translation may need to be revised:
|- R/translate-roxygen.R -x-> man-lang/es/translate-roxygen.R
ℹ Creating Rd files from man-lang/es (Spanish)
- ./inst/man-lang/es/help.Rd
- ./inst/man-lang/es/lang_help.Rd
- ./inst/man-lang/es/process_roxygen.Rd
- ./inst/man-lang/es/reexports.Rd
- ./inst/man-lang/es/to_iso639.Rd
- ./inst/man-lang/es/translate_roxygen.Rd
```

### Using your package’s translations

The end-user can easily access your translations by making sure that
`lang` is loaded to their R session:

``` r
library(lang)

Sys.setenv(LANGUAGE = "spanish")

?lang_help
```

`lang` always looks first in the **‘inst/man-lan’** folder of your
package to see if there is a folder matching the end-user’s language. If
it does not find one, it will then trigger a live translation of the
function. This would be the case if the user expect a French
translation, but you only included a Spanish one.

Instead of having the user wait for the LLM to complete the translation,
if `lang` finds a matching translation in your package, the help page
will appear almost instantly.

Under the hood, `lang` will use the value of your environment variables
to determine which sub-folder to check. If the value of `LANG` is a full
locale value (`en_US.UTF8`), then it will check in the folder matching
the variables first two characters exist. If the value is not a locale,
`lang` will attempt to translate the value into an ISO 639 code. This
package contains a small conversion table to do its best to infer the
language you are using, and thus to know which sub-folder to look for.
