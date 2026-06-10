# lang 0.1.2

## Bug fixes

* When the input is 10 words or fewer, the context summary is now omitted from the translation prompt. Local LLMs can get confused by a context summary that is much longer than the field being translated, causing them to paraphrase the context instead of translating the input.

# lang 0.1.1

## New features

* `lang_use()` and `lang_help()` gain a `context_size` argument (`.context_size`
  in `lang_use()`). When set, a short summary of the full help page is generated
  and injected into the translation prompt for every field, giving the LLM
  consistent terminology across sections. Defaults to `100` words; set to `0`
  to disable.

## Improvements

* Rd parsing has been rewritten to use a structured intermediate list
  (`rd_to_list()` / `list_to_rd()`) instead of regex-based text manipulation.
  This makes translations more reliable and eliminates a class of edge-case
  formatting errors.
