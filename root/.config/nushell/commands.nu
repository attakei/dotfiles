export def --env --wrapped ghq [...rest] {
  if ($rest | is-empty) {
    cd (^ghq list --full-path | fzf | decode utf-8 | str trim)
  } else {
    ^ghq ...$rest
  }
}
