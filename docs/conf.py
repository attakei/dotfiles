# -- Project information
project = "dotfiles"
copyright = "2024, Kazuya Takei"
author = "Kazuya Takei"
release = "0"

# -- General configuration
extensions = [
    # Built-in extensions
    "sphinx.ext.todo",
    # My extensions
    "atsphinx.footnotes",
]
templates_path = ["_templates"]
exclude_patterns = ["_build", "Thumbs.db", ".DS_Store"]
language = "ja"

# -- Options for HTML output
html_theme = "bulma-basic"
html_static_path = ["_static"]
html_title = "attakei's dotfiles"
html_short_title = "attakei's dotfiles"
