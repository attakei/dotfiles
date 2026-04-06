# Shortcuts for Zellij

use ../vendor/nu_scripts/custom-completions/zellij/zellij-completions.nu *

const DOTFILES_APP_DIR = path self | path expand | path dirname | path dirname | path dirname

export-env {
  let config_dir = $DOTFILES_APP_DIR | path join 'Zellij'
  $env.ZELLIJ_CONFIG_DIR = $config_dir
  $env.SHELL = which nu | get path.0
}

# Function
export def --env zellijp [] {
  let name = $env.PWD | path basename
  if ($name in (^zellij list-sessions -n -s| lines)) {
    ^zellij attach $name
  } else {
    ^zellij -s $name
  }
}

# Aliases
export alias zl = zellij list-sessions
export alias zd = zellij delete-session
export alias zp = zellijp
