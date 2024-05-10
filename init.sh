#!/bin/bash

if [ "$(uname)" == "Darwin" ] ; then
	.bin/macos.sh
	# Amazon Q setting file
	ln -snfv ${PWD}/amazon-q_settings.json "${HOME}/Library/Application Support/amazon-q/settings.json"
fi

# symlink
IGNORE_PATTERN="^\.(git|bin|config)"
BASEDIR=$(dirname $0)
cd $BASEDIR

DIR_SYMLINKS=(
	".config/git/ignore"
	".config/starship.toml"
	".config/sheldon/plugins.toml"
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
