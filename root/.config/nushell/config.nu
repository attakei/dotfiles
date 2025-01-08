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

# Load local settings
const _local_nu = './local.nu' | path expand
source (if ($_local_nu | path exists) { $_local_nu }  else { './local_fallback.nu' })
