# ================================
# Entrypoint for set up Windows OS
# ================================

# Scoop
# =====
Set-ExecutionPolicy -ExecutionPolicy RemoteSigned -Scope CurrentUser
Invoke-RestMethod -Uri https://get.scoop.sh | Invoke-Expression
