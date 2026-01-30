Invoke-Expression (&starship init powershell)
(&mise activate pwsh) | Out-String | Invoke-Expression

# commands
function cdrepo {
    $repodir = ghq list | fzf -1 +m
    if ($repodir) {
        Set-Location "$(ghq root)/$repodir"
    }
}

function coderepo {
    $repodir = ghq list | fzf -1 +m
    if ($repodir) {
        Write-Host "Open VSCode WorkSpace!: $(ghq root)/$repodir"
        code "$(ghq root)/$repodir"
    }
}

function delete-merged-branch {
    git branch --merged |
        Where-Object { $_ -notmatch '^\*|master|main|dev|develop' } |
        ForEach-Object { git branch -d $_.Trim() }
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
