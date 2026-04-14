# Custom config for NeoVim

# List of Nushell keybindings that I want to disable in the NeoVim's internal terminal
const NVIM_DISABLE_KEYBINDGS = [
  'fuzzy_ghq',  # Currently, it uses Ctrl-W that is used for moving accross panes.
]

export-env {
  if "NVIM" in $env {
    $env.config.keybindings = $env.config.keybindings | where name not-in $NVIM_DISABLE_KEYBINDGS
  }
}
