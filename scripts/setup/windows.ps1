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

# Import current config and apps
# ------------------------------
scoop import files/scoop-lock.json

# Run shared setup script
# =======================
Set-Location $PSScriptRoot\..\..\
nu script/setup.nu
