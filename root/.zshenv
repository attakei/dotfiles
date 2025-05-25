# --------------------------------------
# - Zsh environment for me (cross-env)
# --------------------------------------

# Force reset path
path=(
  "$HOME/.local/bin"
  "/usr/local/sbin"
  "/usr/local/bin"
  "/usr/sbin"
  "/usr/bin"
  "/sbin"
  "/bin"
  "/usr/local/games"
  "/usr/games"
  "/snap/bin"
)
path=(
  ${AQUA_ROOT_DIR:-${XDG_DATA_HOME:-$HOME/.local/share}/aquaproj-aqua}/bin
  $HOME/.nimble/bin
  $HOME/.cargo/bin
  $HOME/.local/share/mise/bin
  $path
)

# Docker-rootless
if [ "$XDG_RUNTIME_DIR" = "" ] ; then
  export XDG_RUNTIME_DIR="$HOME/.local/runtime"
fi
export DOCKER_HOST=unix://$XDG_RUNTIME_DIR/docker.sock
export DOCKER_CONFIG=$HOME/.local/opt/docker-config

# Editor on shell
export EDITOR=`which vim`

# Load machine-local .zshenv
if [ -e "$HOME/.zshenv.local" ] ; then
  source "$HOME/.zshenv.local"
fi

