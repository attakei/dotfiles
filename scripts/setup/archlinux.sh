#!/usr/bin/env bash
# ================================
# Entrypoint for set up Arch Linux
# ================================

set -euo pipefail

# Fetch repository
REPO_PATH="$HOME/ghq/github.com/attakei/dotfiles"
if [ ! -d "$REPO_PATH" ]; then
    git clone https://github.com/attakei/dotfiles.git "$REPO_PATH"
fi
cd "$REPO_PATH"

# Aqua environment variables
# ==========================
# Write to a dedicated env file and source it from ~/.profile.
# This works for WSL (no systemd), TTY, and desktop login shells alike.
AQUA_ENV_FILE="$HOME/.config/aqua-env.sh"
mkdir -p "$(dirname "$AQUA_ENV_FILE")"

cat > "$AQUA_ENV_FILE" <<EOF
export AQUA_GLOBAL_CONFIG="$REPO_PATH/app/aqua/aqua.yaml"
export AQUA_POLICY_CONFIG="$REPO_PATH/app/aqua/aqua-policy.yaml"
export PATH="$HOME/.local/share/aquaproj-aqua/bin:\$PATH"
EOF

PROFILE="$HOME/.profile"
if ! grep -q "aqua-env.sh" "$PROFILE" 2>/dev/null; then
    cat >> "$PROFILE" <<'EOF'

# Aqua
[ -f "$HOME/.config/aqua-env.sh" ] && . "$HOME/.config/aqua-env.sh"
EOF
fi

export AQUA_GLOBAL_CONFIG="$REPO_PATH/app/aqua/aqua.yaml"
export AQUA_POLICY_CONFIG="$REPO_PATH/app/aqua/aqua-policy.yaml"
export PATH="$HOME/.local/share/aquaproj-aqua/bin:$PATH"
