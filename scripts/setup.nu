# ----
# Set up environment that works on cross-platform.
# ----

# Environment information
let OS_NAME = (uname | get kernel-name)
let PD = if (uname | get kernel-name | str contains 'Windows_NT') { '\' } else {'/'}
let HOME = if (uname | get kernel-name | str contains 'Windows_NT') { $env.USERPROFILE } else { $env.HOME }
# From settings
let links = open settings.yaml | get links

# Pseudo templating to inject environment variables into string.
def inject_env [src: string] {
  let replacements = ['APPDATA', 'HOME', 'USERPROFILE']
  mut val = $src
  for $r in $replacements {
    let k = $'{{($r)}}'
    if ( $val | str contains $k ) {
      let v = $env | get $r
      $val = $val | str replace $k $v
    } 
  }
  return $val
};

# Create symlinks
for $link in $links {
  let source = $link.source | str replace -a '/' $PD
  let source_resolved = $'($env.PWD)($PD)($source)'
  let target = $link.targets | get -o (uname | get kernel-name)
  if ($target == null) {
    continue
  }
  let target_resolved = inject_env $target
  if ( uname | get kernel-name | str contains 'Windows_NT') {
    if ( $target_resolved | path exists ) {
      rm -rf $target_resolved
    }
    mkdir ($target_resolved | path join '..')
    if ((echo $source_resolved | path type) == 'file') {
      mklink $target_resolved $source_resolved
    } else {
      mklink /D $target_resolved $source_resolved
    }
  } else {
    mkdir ($target_resolved | path dirname)
    ln -snf $source_resolved $target_resolved
  }
}

# Configure Starship
if (not ($'($HOME)/.cache/starship/init.nu' | path exists)) {
  mkdir $"($HOME)/.cache/starship"
  starship init nu | save -f ~/.cache/starship/init.nu
}

# Configure aqua (Windows only)
if ( $OS_NAME == "Windows_NT") {
  ^setx AQUA_GLOBAL_CONFIG ($env.PWD | path join 'aqua\aqua.yaml')
  ^setx AQUA_POLICY_CONFIG ($env.PWD | path join 'aqua\aqua-policy.yaml')
  $env.AQUA_GLOBAL_CONFIG = ($env.PWD | path join 'aqua\aqua.yaml')
  $env.AQUA_POLICY_CONFIG = ($env.PWD | path join 'aqua\aqua-policy.yaml')
}
