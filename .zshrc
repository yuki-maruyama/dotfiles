case ${OSTYPE} in
	darwin*)
		export PATH="/opt/homebrew/bin:$HOME/.local/bin:$PATH"
    export PATH="/opt/homebrew/sbin:$PATH"
    export LIBRARY_PATH="/opt/homebrew/lib/:$LIBRARY_PATH"
    export C_INCLUDE_PATH="/opt/homebrew/include/:$C_INCLUDE_PATH"
    export LD_LIBRARY_PATH="/opt/homebrew/lib/:$LD_LIBRARY_PATH"
    export CPLUS_INCLUDE_PATH="/opt/homebrew/include/:$CPLUS_INCLUDE_PATH"
    export GPG_TTY=$(tty)

    export PATH="/opt/homebrew/opt/mysql-client@8.0/bin:$PATH"

    export PNPM_HOME="$HOME/Library/pnpm"
    export PATH="$PNPM_HOME:$PATH"
		;;
	linux*)
    export PATH="$HOME/.local/bin:$PATH"

    export PNPM_HOME="$HOME/.local/share/pnpm"
    export PATH="$PNPM_HOME:$PATH"
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
## mise
if type mise &>/dev/null
then
  eval "$(mise activate zsh)"
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
## direnv
if type direnv &>/dev/null
then
  eval "$(direnv hook zsh)"
fi
## gwq
if type gwq &>/dev/null
then
  source <(gwq completion zsh)
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
_repo_list() {
  ghq list | fzf -1 +m
}

cdrepo() {
  local repodir=$(_repo_list) && [ -n "$repodir" ] && cd $(ghq root)/$repodir
}

coderepo() {
  local repodir=$(_repo_list)
  if [ -n "$repodir" ]; then
    echo Open VSCode WorkSpace! : $(ghq root)/$repodir
    code $(ghq root)/$repodir
  fi
}

codewebstorm() {
  local repodir=$(_repo_list)
  if [ -n "$repodir" ]; then
    echo Open WebStorm WorkSpace! : $(ghq root)/$repodir
    webstorm $(ghq root)/$repodir
  fi
}

codegoland() {
  local repodir=$(_repo_list)
  if [ -n "$repodir" ]; then
    echo Open GoLand WorkSpace! : $(ghq root)/$repodir
    goland $(ghq root)/$repodir
  fi
}

delete-merged-branch() {
  git branch --merged | grep -v "\\*\\|master\\|main\\|dev\\|develop" | xargs -I % git branch -d %

  # Delete merged gwq worktrees
  if type gwq &>/dev/null && type jq &>/dev/null; then
    gwq list --json 2>/dev/null | jq -r '.[] | select(.is_main == false and .branch != "HEAD") | "\(.path)\t\(.branch)"' | while IFS=$'\t' read -r wt_path wt_branch; do
      local default_branch=""
      for candidate in main master; do
        if git -C "$wt_path" rev-parse --verify "origin/$candidate" &>/dev/null; then
          default_branch="$candidate"
          break
        fi
      done
      [ -z "$default_branch" ] && continue

      if git -C "$wt_path" merge-base --is-ancestor HEAD "origin/$default_branch" 2>/dev/null; then
        echo "Removing merged worktree: $wt_branch ($wt_path)"
        gwq remove -b "$wt_path"
      fi
    done
  fi
}

export-envrc() {
  grep -v '^\s*#' .envrc | grep -v '^\s*$' | sed 's/^export //' | sed 's/ *#.*$//' | paste -sd ';' -
}

openhls() {
  case $OSTYPE in
    darwin*)
      open -a "QuickTime Player" "$1"
      ;;
    linux*)
      mpv --hls-live-edge=5 "$1"
      ;;
  esac
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
