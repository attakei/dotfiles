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
# Write to a dedicated env file and source it from both ~/.profile and ~/.bashrc.
# - ~/.profile: TTY login shells, desktop login sessions
# - ~/.bashrc:  WSL default (non-login interactive bash)
AQUA_ENV_FILE="$HOME/.config/aqua-env.sh"
mkdir -p "$(dirname "$AQUA_ENV_FILE")"

cat > "$AQUA_ENV_FILE" <<EOF
export AQUA_GLOBAL_CONFIG="$REPO_PATH/app/aqua/aqua.yaml"
export AQUA_POLICY_CONFIG="$REPO_PATH/app/aqua/aqua-policy.yaml"
export PATH="$HOME/.local/share/aquaproj-aqua/bin:\$PATH"
EOF

SOURCE_LINE='[ -f "$HOME/.config/aqua-env.sh" ] && . "$HOME/.config/aqua-env.sh"'

for RC in "$HOME/.profile" "$HOME/.bashrc"; do
    if ! grep -q "aqua-env.sh" "$RC" 2>/dev/null; then
        printf '\n# Aqua\n%s\n' "$SOURCE_LINE" >> "$RC"
    fi
done

# Launch Nushell from bash when interactive
# ==========================
# nu is managed by aqua, so it cannot be set as login shell directly.
# Instead, keep bash as login shell and exec nu after PATH is configured.
BASHRC="$HOME/.bashrc"
if ! grep -q "exec nu" "$BASHRC" 2>/dev/null; then
    cat >> "$BASHRC" <<'EOF'

# Launch nu (managed by aqua) as interactive shell
if [ -z "${NU_LAUNCHED:-}" ] && [ -n "${WSL_DISTRO_NAME:-}" ] && command -v nu >/dev/null 2>&1; then
    export NU_LAUNCHED=1
    exec nu
fi
EOF
fi

export AQUA_GLOBAL_CONFIG="$REPO_PATH/app/aqua/aqua.yaml"
export AQUA_POLICY_CONFIG="$REPO_PATH/app/aqua/aqua-policy.yaml"
export PATH="$HOME/.local/share/aquaproj-aqua/bin:$PATH"
