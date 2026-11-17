#!/usr/bin/env bash
# ================================
# Entrypoint for set up macOS
# ================================

set -euo pipefail

# Prerequisites
# ==========================
# git is provided by Xcode Command Line Tools on macOS.
if ! command -v git >/dev/null 2>&1; then
    echo "git is not found. Run 'xcode-select --install' first." >&2
    exit 1
fi

# Fetch repository
REPO_PATH="$HOME/ghq/github.com/attakei/dotfiles"
if [ ! -d "$REPO_PATH" ]; then
    git clone https://github.com/attakei/dotfiles.git "$REPO_PATH"
fi
cd "$REPO_PATH"

# Aqua environment variables
# ==========================
# Write to a dedicated env file and source it from both ~/.zprofile and ~/.zshrc.
# - ~/.zprofile: login shells (Terminal.app opens login shells by default)
# - ~/.zshrc:    interactive non-login shells (e.g. tmux, IDE terminals)
AQUA_ENV_FILE="$HOME/.config/aqua-env.sh"
mkdir -p "$(dirname "$AQUA_ENV_FILE")"

cat > "$AQUA_ENV_FILE" <<EOF
export AQUA_GLOBAL_CONFIG="$REPO_PATH/app/aqua/aqua.yaml"
export AQUA_POLICY_CONFIG="$REPO_PATH/app/aqua/aqua-policy.yaml"
export PATH="$HOME/.local/share/aquaproj-aqua/bin:\$PATH"
EOF

SOURCE_LINE='[ -f "$HOME/.config/aqua-env.sh" ] && . "$HOME/.config/aqua-env.sh"'

for RC in "$HOME/.zprofile" "$HOME/.zshrc"; do
    if ! grep -q "aqua-env.sh" "$RC" 2>/dev/null; then
        printf '\n# Aqua\n%s\n' "$SOURCE_LINE" >> "$RC"
    fi
done

# Launch Nushell from zsh when interactive
# ==========================
# nu is managed by aqua, so it cannot be set as login shell directly.
# Instead, keep zsh as login shell and exec nu after PATH is configured.
ZSHRC="$HOME/.zshrc"
if ! grep -q "exec nu" "$ZSHRC" 2>/dev/null; then
    cat >> "$ZSHRC" <<'EOF'

# Launch nu (managed by aqua) as interactive shell
if [ -z "${NU_LAUNCHED:-}" ] && command -v nu >/dev/null 2>&1; then
    export NU_LAUNCHED=1
    exec nu
fi
EOF
fi

export AQUA_GLOBAL_CONFIG="$REPO_PATH/app/aqua/aqua.yaml"
export AQUA_POLICY_CONFIG="$REPO_PATH/app/aqua/aqua-policy.yaml"
export PATH="$HOME/.local/share/aquaproj-aqua/bin:$PATH"
