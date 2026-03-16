Invoke-Expression (&starship init powershell)
(&mise activate pwsh) | Out-String | Invoke-Expression

# commands
function Get-RepoList {
    ghq list | Sort-Object -Unique | fzf -1 +m
}

function cdrepo {
    $repodir = Get-RepoList
    if ($repodir) {
        Set-Location "$(ghq root)/$repodir"
    }
}

function coderepo {
    $repodir = Get-RepoList
    if ($repodir) {
        Write-Host "Open VSCode WorkSpace!: $(ghq root)/$repodir"
        code "$(ghq root)/$repodir"
    }
}

function delete-merged-branch {
    git branch --merged |
        Where-Object { $_ -notmatch '^\*|master|main|dev|develop' } |
        ForEach-Object { git branch -d $_.Trim() }

    # Delete merged gwq worktrees
    if (Get-Command gwq -ErrorAction SilentlyContinue) {
        $worktrees = gwq list --json 2>$null | ConvertFrom-Json
        foreach ($wt in $worktrees) {
            if ($wt.is_main -or $wt.branch -eq "HEAD") { continue }
            $defaultBranch = $null
            foreach ($candidate in @("main", "master")) {
                git -C $wt.path rev-parse --verify "origin/$candidate" 2>$null | Out-Null
                if ($LASTEXITCODE -eq 0) {
                    $defaultBranch = $candidate
                    break
                }
            }
            if (-not $defaultBranch) { continue }

            git -C $wt.path merge-base --is-ancestor HEAD "origin/$defaultBranch" 2>$null | Out-Null
            if ($LASTEXITCODE -eq 0) {
                Write-Host "Removing merged worktree: $($wt.branch) ($($wt.path))"
                gwq remove -b $wt.path
            }
        }
    }
}

# keybind
Set-PSReadLineKeyHandler -Chord 'Ctrl+r' -ScriptBlock {
    $historyPath = (Get-PSReadLineOption).HistorySavePath
    $command = Get-Content $historyPath |
        Where-Object { $_ } |
        Select-Object -Unique |
        fzf --tac --no-sort
    if ($command) {
        [Microsoft.PowerShell.PSConsoleReadLine]::RevertLine()
        [Microsoft.PowerShell.PSConsoleReadLine]::Insert($command)
    }
}
