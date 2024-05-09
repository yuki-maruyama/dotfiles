# ------
# hooks
. "$HOME/.asdf/asdf.sh" ## asdf
eval "$(direnv hook zsh)" ## direnv
eval "$(starship init zsh)" ## starship


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