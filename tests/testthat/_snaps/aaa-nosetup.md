# lang_help() errors clearly when no backend is configured

    Code
      lang_help("lm", "stats", lang = "spanish")
    Condition
      Error:
      ! No LLM backend configured. Call `lang_use()` first.

