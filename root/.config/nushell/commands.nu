export def --env --wrapped ghq [...rest] {
  if ($rest | is-empty) {
    cd (^ghq list --full-path | fzf | decode utf-8 | str trim)
  } else {
    ^ghq ...$rest
  }
}

export def --env zellijp [] {
  let name = $env.PWD | path basename
  if ($name in (zellij list-sessions -n -s| lines)) {
    zellij attach $name
  } else {
    zellij -s $name
  }
}

export def nvimp [...rest] {
  if ( $env.PWD | path join 'uv.lock' | path exists) {
    uv run nvim
  }
}

export def --wrapped uvm [...rest] {
  uv run python -m ...$rest
}
