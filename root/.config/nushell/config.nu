use ~/.cache/starship/init.nu
use vendor/nu_scripts/aliases/git/git-aliases.nu *
use vendor/nu_scripts/custom-completions/git/git-completions.nu *
use ./aliases.nu *
use ./commands.nu *
use ./apps/zellij.nu *

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

# aqua
# const DOTFILES_ROOT = path self | path join .. ..
const DOTFILES_ROOT = path self | path expand | path join ..... | path expand
$env.AQUA_GLOBAL_CONFIG = ($DOTFILES_ROOT | path join 'aqua' 'aqua.yaml') + ($env.AQUA_GLOBAL_CONFIG? | "")
$env.AQUA_POLICY_CONFIG = ($DOTFILES_ROOT | path join 'aqua' 'aqua-policy.yaml' ) + ($env.AQUA_POLICY_CONFIG? | "")
if (uname | get kernel-name | str contains 'Windows_NT') {
  let aqua_bin = $env.USERPROFILE + '\AppData\Local\aquaproj-aqua\bin'
  if ($aqua_bin not-in $env.PATH) {
    $env.PATH = $env.PATH | prepend $aqua_bin
  }
} else {
  # TODO: Path settings for Linux
}
