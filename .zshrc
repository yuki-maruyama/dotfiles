case ${OSTYPE} in
	darwin*)
		export PATH="/opt/homebrew/bin/:$PATH"
		;;
	linux*)
		#linux
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
## asdf
if [ -f "$HOME/.asdf/asdf.sh" ];
then
  eval . "$HOME/.asdf/asdf.sh"
fi
## starship
if type starship &>/dev/null
then
  eval "$(starship init zsh)"
fi


# paths
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

function fzf-select-history() {
    BUFFER=$(history -n -r 1 | fzf --query "$LBUFFER")
    CURSOR=$#BUFFER
    zle reset-prompt
}

# keybind
zle -N fzf-select-history
bindkey '^r' fzf-select-history
