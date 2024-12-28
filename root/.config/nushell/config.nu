use ~/.cache/starship/init.nu
use ./commands.nu *


# keybindings
$env.config.keybindings = $env.config.keybindings | append [
  {
    name: fuzzy_ghq
    modifier: control
    keycode: char_g
    mode: emacs
    event: {
      send: executehostcommand,
      cmd: "ghq",
    }
  }
]
