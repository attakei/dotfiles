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

# Aqua environment variables
# ==========================
if (-not [System.Environment]::GetEnvironmentVariable("AQUA_GLOBAL_CONFIG", "User")) {
    $value = Join-Path $repoPath "app\aqua\aqua.yaml"
    [System.Environment]::SetEnvironmentVariable("AQUA_GLOBAL_CONFIG", $value, "User")
    $env:AQUA_GLOBAL_CONFIG = $value
}
if (-not [System.Environment]::GetEnvironmentVariable("AQUA_POLICY_CONFIG", "User")) {
    $value = Join-Path $repoPath "app\aqua\aqua-policy.yaml"
    [System.Environment]::SetEnvironmentVariable("AQUA_POLICY_CONFIG", $value, "User")
    $env:AQUA_POLICY_CONFIG = $value
}
$aquaBinPath = Join-Path $env:LOCALAPPDATA "aquaproj-aqua\bin"
$userPath = [System.Environment]::GetEnvironmentVariable("PATH", "User")
if ($userPath -notlike "*$aquaBinPath*") {
    [System.Environment]::SetEnvironmentVariable("PATH", "$aquaBinPath;$userPath", "User")
    $env:PATH = "$aquaBinPath;$env:PATH"
}

# Configure Scoop
$env:PATH = "$env:USERPROFILE\scoop\shims;$env:PATH"
if (-not (Get-Command scoop -ErrorAction SilentlyContinue)) {
    Invoke-RestMethod -Uri https://get.scoop.sh | Invoke-Expression
}
scoop import files/scoop-lock.json
