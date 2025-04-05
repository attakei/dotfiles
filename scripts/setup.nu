# ----
# Set up environment that works on cross-platform.
# ----

# Environment information
let PD = if (uname | get kernel-name | str contains 'Windows_NT') { '\' } else {'/'}
let HOME = if (uname | get kernel-name | str contains 'Windows_NT') { $env.USERPROFILE } else { $env.HOME }
# From settings
let links = open settings.toml | get links

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
  let target = $link.targets | get (uname | get kernel-name)
  let target_resolved = inject_env $target
  if ( uname | get kernel-name | str contains 'Windows_NT') {
    if ( $target_resolved | path exists ) {
      rm -rf $target_resolved
    }
    if ((echo $source_resolved | path type) == 'file') {
      mklink $target_resolved $source_resolved
    } else {
      mklink /D $target_resolved $source_resolved
    }
  } else {
    ln -snf $source_resolved $target_resolved
  }
}

# Install all global toolchaions
mise i

# Configure Starship
if (not ($'($HOME)/.cache/starship/init.nu' | path exists)) {
  mkdir $"($HOME)/.cache/starship"
  starship init nu | save -f ~/.cache/starship/init.nu
} 
