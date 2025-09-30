# Empty lang_use() returns 'unset'

    Code
      lang_use(.lang = "english")
    Message
      --- `lang` session
      Backend: [Unset]
      Language: english

# lang_use() works

    Code
      lang_use("simulate_llm", "echo", .cache = "path/to/cache", .lang = "test")
    Message
      --- `lang` session
      Backend: Ollama
      Model: echo
      Cache: path/to/cache
      Language: test

# lang_use() works with ellmer

    Code
      lang_use(x, .cache = "path/to/cache", .lang = "test")
    Message
      --- `lang` session
      Backend: 'test_name' via `ellmer`
      Model: test_model
      Cache: path/to/cache
      Language: test

# lang_use() works with additional arguments

    Code
      lang_use("simulate_llm", "echo", temp = 0.8, .cache = "path/to/cache", .lang = "test")
    Message
      --- `lang` session
      Backend: Ollama
      Model: echo
      Cache: path/to/cache
      Language: test

# lang_use() works with disabled cache

    Code
      lang_use("simulate_llm", "echo", .cache = "", .lang = "test")
    Message
      --- `lang` session
      Backend: Ollama
      Model: echo
      Cache: [Disabled]
      Language: test

