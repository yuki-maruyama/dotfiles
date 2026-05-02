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
if command -v sheldon >/dev/null 2>&1; then
  eval "$(sheldon source)"
fi

# brew installed commands (macOS)
completion_dir_found=false
for fpath_dir in /opt/homebrew/share/zsh/site-functions /usr/local/share/zsh/site-functions; do
  if [ -d "$fpath_dir" ]; then
    FPATH="$fpath_dir:${FPATH}"
    completion_dir_found=true
  fi
done

if [ "$completion_dir_found" = true ]; then
  autoload -Uz compinit
  zcompdump="${ZDOTDIR:-$HOME}/.zcompdump"
  if [ -s "$zcompdump" ]; then
    compinit -C -d "$zcompdump"
  else
    compinit -d "$zcompdump"
  fi
  zstyle ':completion:*' matcher-list 'm:{a-z}={A-Z}'
fi

# hooks
## mise
if command -v mise >/dev/null 2>&1
then
  eval "$(mise activate zsh --shims)"
fi
## starship
if command -v starship >/dev/null 2>&1 && [[ "$TERM" != "dumb" && (-z "$NO_STARSHIP" || "$NO_STARSHIP" != "true") ]]
then
  eval "$(starship init zsh)"
fi
## gpg
export GPG_TTY=${GPG_TTY:-$(tty)}
## direnv
if command -v direnv >/dev/null 2>&1
then
  eval "$(direnv hook zsh)"
fi
## gwq
if command -v gwq >/dev/null 2>&1
then
  gwq_completion_cache="${XDG_CACHE_HOME:-$HOME/.cache}/zsh/gwq-completion.zsh"
  if [ ! -s "$gwq_completion_cache" ] || [ "$gwq_completion_cache" -ot "$(command -v gwq)" ]; then
    mkdir -p "${gwq_completion_cache:h}"
    gwq completion zsh >| "$gwq_completion_cache" 2>/dev/null
  fi
  [ -r "$gwq_completion_cache" ] && source "$gwq_completion_cache"
fi
## paths
if [ -d "$HOME/go/bin" ]
then
  export PATH="$PATH:$HOME/go/bin"
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
if [[ "$DOTFILES_CHECK_UPDATES" == "true" && -d "$HOME/dotfiles" ]]; then
  if test -n "$(git -C $HOME/dotfiles status --porcelain)"; then
    echo -e "\033[0;31m[dotfiles] You have uncommitted changes in your dotfiles repository.\033[0m"
  elif test -n "$(git -C $HOME/dotfiles diff --stat --cached origin/master)"; then
    echo -e "\033[0;33m[dotfiles] Your dotfiles repository is behind the remote.\033[0m"
  fi
fi
