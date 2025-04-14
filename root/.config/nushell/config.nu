use ~/.cache/starship/init.nu
use vendor/nu_scripts/aliases/git/git-aliases.nu *
use vendor/nu_scripts/custom-completions/git/git-completions.nu *
use ./aliases.nu *
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
    keycode: char_w
    mode: emacs
    event: {
      send: executehostcommand,
      cmd: "ghq",
    }
  }
]
