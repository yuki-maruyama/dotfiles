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

# install mise plugins
MISE_PLUGINS=(
  "ghq"
)

for plugin in ${MISE_PLUGINS[@]}; do
  mise install $plugin
  mise use $plugin
done

# install starship
if type starship &>/dev/null
then
  echo "starship is already installed"
else
  sh -c "$(curl -fsSL https://starship.rs/install.sh)"
fi
