#!/bin/bash

# Install xcode
if type git &>/dev/null
then
  echo "xcode is already installed"
else
  xcode-select --install > /dev/null
fi

# Install brew
if type brew &>/dev/null
then
  echo "brew is already installed"
else
  /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
fi

# Install brew packages
BREW_PACKAGES=(
  "zsh-autosuggestions"
  "zsh-fast-syntax-highlighting"
  "fzf"
  "ghq"
  "starship"
)

brew install ${BREW_PACKAGES[@]}