param(
    [switch]$DryRun,
    [switch]$Force,
    [switch]$NoInstall
)

$ErrorActionPreference = "Stop"

$scriptPath = $MyInvocation.MyCommand.Path
$scriptDirectory = Split-Path -Parent $scriptPath

function Invoke-Action {
    param(
        [scriptblock]$Action,
        [string]$Description
    )

    if ($DryRun) {
        Write-Host "[dry-run] $Description"
    } else {
        & $Action
    }
}

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

if (-not $NoInstall) {
    # set execution policy to Administrators
    if (!([Security.Principal.WindowsPrincipal][Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole("Administrators")) {
        $args = @("-File", "`"$PSCommandPath`"")
        if ($DryRun) { $args += "-DryRun" }
        if ($Force) { $args += "-Force" }
        Start-Process pwsh ($args -join " ") -Verb RunAs
        exit
    }

    Write-Host "Installing packages from winget"
    foreach ($wingetPackage in $wingetPackageList) {
        Write-Host "Installing $wingetPackage"
        Invoke-Action -Description "winget install -e --id $wingetPackage" -Action {
            winget install -e --id $wingetPackage
        }
        Write-Host `n
    }
}

# symlink
$symlinks = @(
    ("$HOME\.config\starship.toml", "$scriptDirectory\.config\starship.toml"),
    ("$HOME\.config\git\ignore", "$scriptDirectory\.config\git\ignore"),
    ("$HOME\.config\gwq\config.toml", "$scriptDirectory\.config\gwq\config.toml"),
    ("$PROFILE", "$scriptDirectory\Microsoft.PowerShell_profile.ps1")
)

function New-SafeSymlink {
    param(
        [string]$Target,
        [string]$Source
    )

    $targetDirectory = Split-Path -Parent $Target
    Invoke-Action -Description "Create directory $targetDirectory" -Action {
        New-Item -ItemType Directory -Path $targetDirectory -Force | Out-Null
    }

    if (Test-Path $Target) {
        $item = Get-Item $Target
        if ($item.LinkType -eq "SymbolicLink") {
            if ($item.Target -eq $Source) {
                Write-Host "Already linked: $Target -> $Source"
                return
            }
            Invoke-Action -Description "Remove symlink $Target" -Action {
                Remove-Item $Target -Force
            }
        } elseif ($Force) {
            Invoke-Action -Description "Remove existing path $Target" -Action {
                Remove-Item $Target -Recurse -Force
            }
        } else {
            $backup = "$Target.backup.$(Get-Date -Format 'yyyyMMddHHmmss')"
            Write-Host "Backing up existing path: $Target -> $backup"
            Invoke-Action -Description "Move $Target to $backup" -Action {
                Move-Item $Target $backup
            }
        }
    }

    Invoke-Action -Description "Create symlink $Target -> $Source" -Action {
        New-Item -ItemType SymbolicLink -Path $Target -Target $Source -Force | Out-Null
    }
}

Write-Host "Creating symlink"
foreach ($symlink in $symlinks) {
    $target = $symlink[0]
    $link = $symlink[1]
    New-SafeSymlink -Target $target -Source $link
}

# wait for user input
if (-not $DryRun) {
    Write-Host "Complete. Press any key to continue..."
    $null = $Host.UI.RawUI.ReadKey("NoEcho,IncludeKeyDown")
}
