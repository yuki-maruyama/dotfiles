# ------
# hooks
## asdf
. "$HOME/.asdf/asdf.sh"
## direnv
eval "$(direnv hook zsh)"

# paths
export PATH="/opt/homebrew/bin/:$PATH"

# aliases
alias chrome="open -a 'Google Chrome'"

# brew installed commands
if type brew &>/dev/null
then
  # zsh-autosuggestion
  source $(brew --prefix)/share/zsh-autosuggestions/zsh-autosuggestions.zsh
  # zsh-fast-syntax-highlighting
  source /opt/homebrew/opt/zsh-fast-syntax-highlighting/share/zsh-fast-syntax-highlighting/fast-syntax-highlighting.plugin.zsh
  # zsh-autocomplete
  FPATH="$(brew --prefix)/share/zsh/site-functions:${FPATH}"
  autoload -Uz compinit
  compinit
fi