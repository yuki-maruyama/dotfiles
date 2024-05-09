#!/bin/bash

if [ "$(uname)" == "Darwin" ] ; then
	.bin/macos.sh
fi

# symlink
IGNORE_PATTERN="^\.(git|bin|config)"
BASEDIR=$(dirname $0)
cd $BASEDIR

DIR_SYMLINKS=(
	".config/git/ignore"
	".config/starship.toml"
)

## home root dir symlink
for f in .??*; do
    [[ $f =~ $IGNORE_PATTERN ]] && continue
		[ "$f" = ".DS_Store" ] && continue

    ln -snfv ${PWD}/"$f" ~
done

## not root dir symlink
for f in ${DIR_SYMLINKS[@]}; do
	ln -snfv ${PWD}/"$f" ~/"$f"
done
