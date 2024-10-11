# install prerequired packages
sudo apt update
sudo apt install zsh curl git unzip gpg -y

# change default shell
if [ $SHELL = "/bin/zsh" ]
then
  echo "zsh is already default shell"
else
  sudo chsh -s $(which zsh)
fi

# install asdf
if [ -d ~/.asdf ]
then
  echo "asdf is already installed"
else
  git clone https://github.com/asdf-vm/asdf.git ~/.asdf --branch v0.14.1
  . "$HOME/.asdf/asdf.sh"
fi

# insatll sheldon
if type sheldon &>/dev/null
then
  echo "sheldon is already installed"
else
  curl --proto '=https' -fLsS https://rossmacarthur.github.io/install/crate.sh \
    | bash -s -- --repo rossmacarthur/sheldon --to ~/.local/bin
fi

# install fzf
if type fzf &>/dev/null
then
  echo "fzf is already installed"
else
  sudo apt install fzf -y
fi

# install ghq
if type ghq &>/dev/null
then
  echo "ghq is already installed"
else
  asdf plugin add ghq
  asdf install ghq latest
  asdf global ghq latest
fi

# install starship
if type starship &>/dev/null
then
  echo "starship is already installed"
else
  sh -c "$(curl -fsSL https://starship.rs/install.sh)"
fi

# install direnv
if type direnv &>/dev/null
then
  echo "direnv is already installed"
else
  sudo apt install direnv -y
fi
