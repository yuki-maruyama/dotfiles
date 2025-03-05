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

# install asdf
if [ -d ~/.asdf ]
then
  echo "asdf is already installed"
else
  git clone https://github.com/asdf-vm/asdf.git ~/.asdf --branch v0.14.1
  . "$HOME/.asdf/asdf.sh"
fi

# Install brew packages
BREW_PACKAGES=(
  "sheldon"
  "fzf"
  "starship"
  "gpg"
  "pinentry-mac"
  "gpg-suite"
)

brew install ${BREW_PACKAGES[@]}

# Install asdf plugins
ASDF_PLUGINS=(
  "direnv"
  "ghq"
)

for plugin in ${ASDF_PLUGINS[@]}; do
  asdf plugin add $plugin
  asdf install $plugin latest
  asdf global $plugin latest
done

# Change menubar item spacing
defaults -currentHost write -globalDomain NSStatusItemSpacing -int 10
defaults -currentHost write -globalDomain NSStatusItemSelectionPadding -int 6