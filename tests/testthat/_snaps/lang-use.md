# Empty lang_use() returns 'unset'

    Code
      lang_use(.lang = "english")
    Message
      Model not set
      Lang: english

# lang_use() works with 'ollama'

    Code
      lang_use("ollama", "model")
    Message
      Model: model via Ollama
      Lang: english

# lang_use() works

    Code
      lang_use("simulate_llm", "echo", .cache = "path/to/cache", .lang = "test")
    Message
      Model: echo via simulate_llm
      Lang: test
      Cache: path/to/cache

# lang_use() works with ellmer

    Code
      lang_use(x, .cache = "path/to/cache", .lang = "test")
    Message
      Model: test_model via test_name
      Lang: test
      Cache: path/to/cache

# lang_use() works with additional arguments

    Code
      lang_use("simulate_llm", "echo", temp = 0.8, .cache = "path/to/cache", .lang = "test")
    Message
      Model: echo via simulate_llm
      Lang: test
      Cache: path/to/cache

# lang_use() works with disabled cache

    Code
      lang_use("simulate_llm", "echo", .cache = "", .lang = "test")
    Message
      Model: echo via simulate_llm
      Lang: test
      Cache: [Disabled]

