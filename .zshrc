# ------
# brew installed commands (macOS)
if type brew &>/dev/null
then
  export PATH="/opt/homebrew/bin/:$PATH"
  # zsh-autosuggestion
  source $(brew --prefix)/share/zsh-autosuggestions/zsh-autosuggestions.zsh
  # zsh-fast-syntax-highlighting
  source /opt/homebrew/opt/zsh-fast-syntax-highlighting/share/zsh-fast-syntax-highlighting/fast-syntax-highlighting.plugin.zsh
  # zsh-autocomplete
  FPATH="$(brew --prefix)/share/zsh/site-functions:${FPATH}"
  autoload -Uz compinit
  compinit
  zstyle ':completion:*' matcher-list 'm:{a-z}={A-Z}'
fi

# hooks
## direnv
if type direnv &>/dev/null
then
  eval "$(direnv hook zsh)"
fi
## asdf
if type asdf &>/dev/null
then
  eval . "$HOME/.asdf/asdf.sh"
fi
## starship
if type starship &>/dev/null
then
  eval "$(starship init zsh)"
fi


# paths

# aliases
alias chrome="open -a 'Google Chrome'"

# commands
cdrepo() {
  local repodir=$(ghq list | fzf -1 +m) && cd $(ghq root)/$repodir
}

coderepo() {
  local repodir=$(ghq list | fzf -1 +m) &&
  echo Open VSCode WorkSpace! : $(ghq root)/$repodir
  if [ -n "$repodir" ]; then
   code $(ghq root)/$repodir
  fi
}
