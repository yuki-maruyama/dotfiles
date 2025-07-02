case ${OSTYPE} in
	darwin*)
		export PATH="/opt/homebrew/bin/:$HOME/.local/bin:$PATH"
    export PATH="/opt/homebrew/sbin:$PATH"
    export LIBRARY_PATH="/opt/homebrew/lib/:$LIBRARY_PATH"
    export C_INCLUDE_PATH="/opt/homebrew/include/:$C_INCLUDE_PATH"
    export LD_LIBRARY_PATH="/opt/homebrew/lib/:$LD_LIBRARY_PATH"
    export CPLUS_INCLUDE_PATH="/opt/homebrew/include/:$CPLUS_INCLUDE_PATH"
    export GPG_TTY=$(tty)

    export PATH="/opt/homebrew/opt/mysql-client@8.0/bin:$PATH"
		;;
	linux*)
    export PATH="$HOME/.local/bin:$PATH"
		;;
esac
# sheldon
eval "$(sheldon source)"

# brew installed commands (macOS)
if type brew &>/dev/null
then
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
## starship
if type starship &>/dev/null && [[ -z "$NO_STARSHIP" || "$NO_STARSHIP" != "true" ]]
then
  eval "$(starship init zsh)"
fi
## gpg
if type gpg &>/dev/null;
then
  export GPG_TTY=$(tty)
fi
## paths
if type go &>/dev/null
then
  export PATH="$PATH:$(go env GOPATH)/bin"
fi

# aliases
alias chrome="open -a 'Google Chrome'"
alias la="ls -la"

# history setting
HISTFILE=~/.zsh_history
HISTSIZE=1000000
SAVEHIST=1000000

setopt share_history
setopt hist_ignore_all_dups
setopt hist_ignore_space
setopt hist_reduce_blanks
setopt hist_save_no_dups
setopt inc_append_history

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

codewebstorm() {
  local repodir=$(ghq list | fzf -1 +m) &&
  echo Open WebStorm WorkSpace! : $(ghq root)/$repodir
  if [ -n "$repodir" ]; then
   webstorm $(ghq root)/$repodir
  fi
}

codegoland() {
  local repodir=$(ghq list | fzf -1 +m) &&
  echo Open GoLand WorkSpace! : $(ghq root)/$repodir
  if [ -n "$repodir" ]; then
   goland $(ghq root)/$repodir
  fi
}

delete-merged-branch() {
  git branch --merged | grep -v "\\*\\|master\\|main\\|dev\\|develop" | xargs -I % git branch -d %
}

export-envrc() {
  grep -v '^\s*#' .envrc | grep -v '^\s*$' | sed 's/^export //' | sed 's/ *#.*$//' | paste -sd ';' -
}

function fzf-select-history() {
    BUFFER=$(history -n -r 1 | fzf --query "$LBUFFER")
    CURSOR=$#BUFFER
    zle reset-prompt
}

# keybind
zle -N fzf-select-history
bindkey '^r' fzf-select-history

# dotfiles update checker
if [ -d "$HOME/dotfiles" ]; then
  if test -n "$(git -C $HOME/dotfiles status --porcelain)"; then
    echo -e "\033[0;31m[dotfiles] You have uncommitted changes in your dotfiles repository.\033[0m"
  elif test -n "$(git -C $HOME/dotfiles diff --stat --cached origin/master)"; then
    echo -e "\033[0;33m[dotfiles] Your dotfiles repository is behind the remote.\033[0m"
  fi
fi
