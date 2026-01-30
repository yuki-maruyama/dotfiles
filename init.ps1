$scriptPath = $MyInvocation.MyCommand.Path
$scriptDirectory = Split-Path -Parent $scriptPath
$profileDirectory = Split-Path -Parent $PROFILE

# set execution policy to Administrators
if (!([Security.Principal.WindowsPrincipal][Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole("Administrators")) { Start-Process pwsh "-File `"$PSCommandPath`"" -Verb RunAs; exit }

# Winget package list
$wingetPackageList = @(
    "7zip.7zip",
    "Starship.Starship",
    "direnv.direnv",
    "Git.Git",
    "x-motemen.ghq",
    "junegunn.fzf",
    "jdx.mise"
)

Write-Host "Installing packages from winget"
# install
foreach ($wingetPackage in $wingetPackageList) {
  Write-Host "Installing $wingetPackage"
  winget install -e --id $wingetPackage
  Write-Host `n
}

# symlink
$symlinks = @(
    ("$HOME\.config\starship.toml", "$scriptDirectory\.config\starship.toml"),
    ("$HOME\.config\git\ignore", "$scriptDirectory\.config\git\ignore"),
    ("$PROFILE", "$scriptDirectory\Microsoft.PowerShell_profile.ps1")
)

Write-Host "Creating symlink"
foreach ($symlink in $symlinks) {
    $target = $symlink[0]
    $link = $symlink[1]
    Write-Host "Creating symlink $link -> $target"
    New-Item -ItemType SymbolicLink -Path $target -Target $link -Force
}

# wait for user input
Write-Host "Complete. Press any key to continue..."
$null = $Host.UI.RawUI.ReadKey("NoEcho,IncludeKeyDown")
