use ./commands.nu *

# For Windows
$env.config.shell_integration = {
    osc2: false
    osc7: false
    osc8: false
    osc9_9: false
    osc133: false
    osc633: false
    reset_application_mode: false
}

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
