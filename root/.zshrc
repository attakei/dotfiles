# --------------------------------------
# - Zsh interactive shell settings for me (cross-env)
# --------------------------------------

# Configure with sheldon
eval "$(sheldon source)"

setopt share_history

# Custom settings for shell
# @source prompt keybinds

# Programming language environments
# path=(
#   $path
# )

# Use starship
eval "$(starship init zsh)"

# Load machine-local .zshenv
if [ -e "$HOME/.zshrc.local" ] ; then
    source "$HOME/.zshrc.local"
fi
