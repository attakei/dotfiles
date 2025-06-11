# Shortcuts for Zellij

# Function
export def --env zellijp [] {
  let name = $env.PWD | path basename
  if ($name in (zellij list-sessions -n -s| lines)) {
    zellij attach $name
  } else {
    zellij -s $name
  }
}

# Aliases
export alias zl = zellij list-sessions
export alias zd = zellij delete-session
export alias zp = zellijp
