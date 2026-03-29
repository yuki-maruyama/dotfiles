#!/bin/bash

if [ "$(uname)" == "Darwin" ] ; then
	.bin/macos.sh
elif [ "$(expr substr $(uname -s) 1 5)" == "Linux" ] ; then
  # check distro
	if [ -e /etc/debian_version ] ; then
		.bin/debian.sh
	else
		echo "Your distro is not supported"
	fi
else
	echo "Your platform is not supported"
	exit 1
fi

# symlink
IGNORE_PATTERN="^\.(git|bin|config|editorconfig)"
BASEDIR=$(dirname $0)
cd $BASEDIR

DIR_SYMLINKS=(
	".config/git/config"
	".config/git/ignore"
	".config/starship.toml"
	".config/sheldon/plugins.toml"
	".config/gwq/config.toml"
)

## home root dir symlink
for f in .??*; do
    [[ $f =~ $IGNORE_PATTERN ]] && continue
		[ "$f" = ".DS_Store" ] && continue

    ln -snfv ${PWD}/"$f" ~
done

## not root dir symlink
for f in ${DIR_SYMLINKS[@]}; do
	dir=$(dirname "$f")

	# Check if the directory exists, if not, create it
  if [ ! -d "$HOME/$dir" ]; then
    mkdir -p "$HOME/$dir"
  fi

	ln -snfv ${PWD}/"$f" "$HOME/$f"
done

## agent skills symlink (.agent/skills -> .claude/skills, .codex/skills)
for d in .claude .codex; do
	mkdir -p "$HOME/$d"
	ln -snfv "$HOME/.agent/skills" "$HOME/$d/skills"
done
