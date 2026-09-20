use vendor/nu_scripts/aliases/git/git-aliases.nu *
use vendor/nu_scripts/custom-completions/git/git-completions.nu *
use ./aliases.nu *
use ./commands.nu *
use ./app/nvim.nu *
use ./app/zellij.nu *

const DOTFILES_ROOT = path self | path expand | path join ..... | path expand
let IS_WINDOWS = (uname | get kernel-name | str contains 'Windows_NT')

mut _paths = []

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

# Shared environment variables
# skkeleton だけを有効にした専用 NeoVim 設定 (app/NeoVim/SKK) を使う。
$env.EDITOR = 'env NVIM_APPNAME=nvim/SKK nvim'
if ('~/.choosenim' | path expand | path exists) {
  if ($IS_WINDOWS) {
    $env.CC = ('~/.choosenim' | path join 'toolchains' 'mingw64' 'bin' 'gcc.exe'| path expand)
  }
}

# bun
if (uname | get kernel-name | str contains 'Windows_NT') {
  let bin_dir = $env.USERPROFILE + '\.bun\bin'
  if ($bin_dir not-in $env.PATH) {
    $env.PATH = $env.PATH | prepend $bin_dir
  }
} else {
  # TODO: Path settings for Linux
}

# Path settings
$_paths = $_paths | append '~/.local/bin'
$_paths = $_paths | append '~/.nimble/bin'
$_paths = $_paths | each {|p| $p | path expand } | where {|p| $p | path exists } | where {|p| not ($p in $env.PATH)}
$env.PATH = $_paths ++ $env.PATH
