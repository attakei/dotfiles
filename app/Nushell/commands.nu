export def --env --wrapped ghq [...rest] {
  if ($rest | is-empty) {
    cd (^ghq list --full-path | fzf | decode utf-8 | str trim)
  } else {
    ^ghq ...$rest
  }
}

export def --wrapped nvimp [...rest] {
  if ( $env.PWD | path join 'uv.lock' | path exists) {
    uv run nvim ...$rest
  }
}
