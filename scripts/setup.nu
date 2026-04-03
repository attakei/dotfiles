# ----
# Set up environment that works on cross-platform.
# ----

# Environment information
let OS_NAME = (uname | get kernel-name)
let PD = if (uname | get kernel-name | str contains 'Windows_NT') { '\' } else {'/'}
let HOME = if (uname | get kernel-name | str contains 'Windows_NT') { $env.USERPROFILE } else { $env.HOME }
# From settings
let links = open settings.yaml | get links

const DOTFILES_ROOT = path self | path expand | path join ... | path expand

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

def make_symlink [src: string, dest: string] {
  mkdir ($dest | path join '..')
  if ( uname | get kernel-name | str contains 'Windows_NT') {
    if ( $dest | path exists) {
      rm -f $dest
    } else if ( $dest | path exists --no-symlink) {
      rm -t $dest
    }
    if (($src | path type) == 'file') {
      mklink $dest $src
    } else {
      mklink /D $dest $src
    }
  } else {
    ln -snf $src $dest
  }
}

# Make symlinks for HOME
for $file in (ls ($DOTFILES_ROOT | path join 'app/HOME')) {
  let filename = $file.name | path basename
  let source_resolved = $file.name | path expand
  let target_resolved = '~' | path expand | path join $filename
  make_symlink $source_resolved $target_resolved
}

# Create symlinks for other directories
for $link in $links {
  let source = $link.source | str replace -a '/' $PD
  let source_resolved = $'($env.PWD)($PD)($source)'
  let target = $link.targets | get -o (uname | get kernel-name)
  if ($target == null) {
    continue
  }
  let target_resolved = inject_env $target
  make_symlink $source_resolved $target_resolved
}

# Configure Oh My Zsh
oh-my-posh init nu
