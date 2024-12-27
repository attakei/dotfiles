use ~/.cache/starship/init.nu


# keybindings
$env.config.keybindings = $env.config.keybindings | append [
  {
    name: fuzzy_ghq
    modifier: control
    keycode: char_g
    mode: emacs
    event: {
      send: executehostcommand,
      cmd: "cd (ghq list --full-path | fzf | decode utf-8 | str trim)"
    }
  }
]
