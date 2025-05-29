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

# aqua
if (uname | get kernel-name | str contains 'Windows_NT') { 
  $env.AQUA_POLICY_CONFIG = ($env.USERPROFILE + '\aqua-policy.yaml;') + ($env.AQUA_POLICY_CONFIG? | "")
  let aqua_bin = $env.USERPROFILE + '\AppData\Local\aquaproj-aqua\bin'
  if ($aqua_bin not-in $env.PATH) {
    $env.PATH = $env.PATH | prepend $aqua_bin
  }
} else {
  $env.AQUA_POLICY_CONFIG = ($env.HOME + '/aqua-policy.yaml:') + ($env.AQUA_POLICY_CONFIG? | "")
  # TODO: Path settings for Linux
}
