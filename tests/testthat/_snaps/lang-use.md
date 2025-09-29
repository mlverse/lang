# lang_use() works

    Code
      lang_use("simulate_llm", "echo", .cache = "path/to/cache")
    Message
      --- `lang` session
      Backend: Ollama
      Model: echo
      Cache: path/to/cache
      Language: en_US.UTF-8
      Language: C

# lang_use() works with ellmer

    Code
      lang_use(x, .cache = "path/to/cache")
    Message
      --- `lang` session
      Backend: 'test_name' via `ellmer`
      Model: test_model
      Cache: path/to/cache
      Language: en_US.UTF-8
      Language: C

# lang_use() works with additional arguments

    Code
      lang_use("simulate_llm", "echo", temp = 0.8, .cache = "path/to/cache")
    Message
      --- `lang` session
      Backend: Ollama
      Model: echo
      Cache: path/to/cache
      Language: en_US.UTF-8
      Language: C

# lang_use() works with disabled cache

    Code
      lang_use("simulate_llm", "echo", .cache = "")
    Message
      --- `lang` session
      Backend: Ollama
      Model: echo
      Cache: [Disabled]
      Language: en_US.UTF-8
      Language: C

