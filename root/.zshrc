# --------------------------------------
# - Zsh interactive shell settings for me (cross-env)
# --------------------------------------

setopt share_history

# Custom settings for shell
# @source prompt keybinds

# Programming language environments
# path=(
#   $path
# )

# Load machine-local .zshenv
if [ -e "$HOME/.zshrc.local" ] ; then
    source "$HOME/.zshrc.local"
fi
