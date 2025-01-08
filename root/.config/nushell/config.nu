use ~/.cache/starship/init.nu
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

# Load local settings
const _local_nu = './local.nu' | path expand
source-env (if ($_local_nu | path exists) { $_local_nu }  else { './local_fallback.nu' })
