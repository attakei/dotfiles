# --------------------------------------
# - Zsh interactive shell settings for me (cross-env)
# --------------------------------------

# Configure with sheldon
eval "$(sheldon source)"

setopt share_history

# Keybinds
bindkey "^[OH" beginning-of-line
bindkey "^[OF" end-of-line
bindkey "^[[3~" delete-char
bindkey '\CA' beginning-of-line
bindkey '\CE' end-of-line

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
