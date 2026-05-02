# dotfiles

Personal dotfiles for macOS, Debian-based Linux, and Windows PowerShell.

## Contents

- zsh configuration
- PowerShell profile
- Git, Starship, Sheldon, and gwq configuration
- Bootstrap scripts for package installation and symlink setup

## Setup

Clone the repository and run the platform setup script.

```sh
git clone https://github.com/yuki-maruyama/dotfiles.git ~/dotfiles
cd ~/dotfiles
./init.sh
```

For Windows PowerShell:

```powershell
git clone https://github.com/yuki-maruyama/dotfiles.git $HOME\dotfiles
cd $HOME\dotfiles
.\init.ps1
```

## Options

Both setup scripts are designed to be re-runnable.

- `--dry-run` / `-DryRun`: print planned actions without changing files.
- `--force` / `-Force`: replace existing non-symlink files instead of backing them up.
- `--no-install` / `-NoInstall`: skip package installation and only create symlinks.

By default, if a target file already exists and is not a symlink, it is moved to a timestamped `.backup.YYYYMMDDHHMMSS` path before the symlink is created.

## Notes

- macOS setup installs packages with Homebrew.
- Debian setup installs required packages with `apt`.
- Windows setup installs packages with `winget`.
- Private or machine-local configuration should not be committed to this repository.
- Set `DOTFILES_CHECK_UPDATES=true` to enable the zsh startup check for local dotfiles changes. It is disabled by default to keep shell startup fast.

## Checks

This repository runs Gitleaks in GitHub Actions to catch accidental secret commits.
