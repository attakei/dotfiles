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

## Config for zeno.zsh
if [[ -n $ZENO_LOADED ]]; then
  # ここに任意のZLEの記述を行う
  bindkey ' '  zeno-auto-snippet
  bindkey '^m' zeno-auto-snippet-and-accept-line
  bindkey '^i' zeno-completion
  bindkey '^w' zeno-ghq-cd
  bindkey '^r' zeno-history-selection
  bindkey '^x' zeno-insert-snippet
fi

# Use starship
if [[ "$(tty)" =~ "/dev/tty[0-9]+" ]] ; then
else
  eval "$(oh-my-posh init zsh)"
fi


# NeoVim using Python virtualenv
function nvimp () {
  if [ -e "poetry.lock" ] ; then
    poetry run nvim $@
  elif [ -e "Pipfile.lock" ] ; then
    pipenv run nvim $@
  elif [ -e "uv.lock" ] ; then
    uv run nvim $@
  else
    nvim $@
  fi
}

function zpwd () {
  repo_name=$(basename `pwd`)
  repo_dir=$(dirname `pwd`)
  org_name=$(basename $repo_dir)
  echo "${org_name}#${repo_name}"
}

# Completions
. <( zellij setup --generate-completion zsh | sed -Ee 's/^(_(zellij) ).*/compdef \1\2/' )


# Load machine-local .zshenv
if [ -e "$HOME/.zshrc.local" ] ; then
    source "$HOME/.zshrc.local"
fi
