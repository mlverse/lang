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
