# ================================
# Entrypoint for set up Windows OS
# ================================
Set-ExecutionPolicy -ExecutionPolicy RemoteSigned -Scope CurrentUser

# Scoop
# =====

# Install
# -------
$env:PATH = "$env:USERPROFILE\scoop\shims;$env:PATH"
if (-not (Get-Command scoop -ErrorAction SilentlyContinue)) {
    Invoke-RestMethod -Uri https://get.scoop.sh | Invoke-Expression
}

# Configuration
# -------------
scoop config aria2-warning-enabled false

# Import current items
# --------------------
scoop import files/scoop-lock.json
