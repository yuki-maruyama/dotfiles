# install prerequired packages
sudo apt update
sudo apt install zsh curl git unzip gpg -y

ARCH=$(uname -m)
if [ $ARCH = "x86_64" ]
then
  echo "x86_64 architecture detected"
  ARCH="amd64"
elif [ $ARCH = "aarch64" ]
then
  echo "aarch64 architecture detected"
  ARCH="arm64"
else
  echo "Unsupported architecture: $ARCH"
  exit 1
fi

# change default shell
if [ $SHELL = "/bin/zsh" ]
then
  echo "zsh is already default shell"
else
  sudo chsh -s $(which zsh)
fi

# install asdf
ASDF_VERSION=v0.18.0
if type -a asdf &>/dev/null
then
  echo "asdf is already installed"
else
    wget https://github.com/asdf-vm/asdf/releases/download/$ASDF_VERSION/asdf-$ASDF_VERSION-linux-$ARCH.tar.gz -O /tmp/asdf.tar.gz
    mkdir -p ~/.local/bin
    tar -xzf /tmp/asdf.tar.gz -C ~/.local/bin --strip-components
    rm /tmp/asdf.tar.gz
fi

# install sheldon
if type sheldon &>/dev/null
then
  echo "sheldon is already installed"
else
  curl --proto '=https' -fLsS https://rossmacarthur.github.io/install/crate.sh \
    | bash -s -- --repo rossmacarthur/sheldon --to ~/.local/bin
fi

# insrtall apt packages
APT_PACKAGES=(
  "fzf"
  "direnv"
  "gh"
)

sudo apt install ${APT_PACKAGES[@]} -y

# install asdf plugins
ASDF_PLUGINS=(
  "ghq"
)

for plugin in ${ASDF_PLUGINS[@]}; do
  asdf plugin add $plugin
  asdf install $plugin latest
  asdf set -u $plugin latest
done

# install starship
if type starship &>/dev/null
then
  echo "starship is already installed"
else
  sh -c "$(curl -fsSL https://starship.rs/install.sh)"
fi
