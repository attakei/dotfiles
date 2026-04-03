use vendor/nu_scripts/aliases/git/git-aliases.nu *
use vendor/nu_scripts/custom-completions/git/git-completions.nu *
use ./aliases.nu *
use ./commands.nu *
use ./app/zellij.nu *

const DOTFILES_ROOT = path self | path expand | path join ..... | path expand

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


# bun
if (uname | get kernel-name | str contains 'Windows_NT') {
  let bin_dir = $env.USERPROFILE + '\.bun\bin'
  if ($bin_dir not-in $env.PATH) {
    $env.PATH = $env.PATH | prepend $bin_dir
  }
} else {
  # TODO: Path settings for Linux
}

# Zellij
if (uname | get kernel-name | str contains 'Windows_NT') {
  $env.ZELLIJ_CONFIG_DIR = $DOTFILES_ROOT | path join 'root' '.config' 'zellij'
  $env.SHELL = which nu | get path.0
}
