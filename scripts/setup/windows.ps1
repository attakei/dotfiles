# ================================
# Entrypoint for set up Windows OS
# ================================
Set-ExecutionPolicy -ExecutionPolicy RemoteSigned -Scope CurrentUser

# Fetch repository
$repoPath = "$env:USERPROFILE\ghq\github.com\attakei\dotfiles"
if (-not (Test-Path $repoPath)) {
    git clone https://github.com/attakei/dotfiles.git $repoPath
}
Set-Location $repoPath

# Configure Scoop
$env:PATH = "$env:USERPROFILE\scoop\shims;$env:PATH"
if (-not (Get-Command scoop -ErrorAction SilentlyContinue)) {
    Invoke-RestMethod -Uri https://get.scoop.sh | Invoke-Expression
}
scoop import files/scoop-lock.json
