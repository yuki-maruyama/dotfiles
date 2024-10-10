$scriptPath = $MyInvocation.MyCommand.Path
$scriptDirectory = Split-Path -Parent $scriptPath
$profileDirectory = Split-Path -Parent $PROFILE

# set execution policy to Administrators
if (!([Security.Principal.WindowsPrincipal][Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole("Administrators")) { Start-Process pwsh.exe "-File `"$PSCommandPath`"" -Verb RunAs; exit }

New-Item -ItemType SymbolicLink -Path $PROFILE -Target $scriptDirectory\Microsoft.PowerShell_profile.ps1 -Force

# wait for user input
Write-Host "Complete. Press any key to continue..."
$null = $Host.UI.RawUI.ReadKey("NoEcho,IncludeKeyDown")