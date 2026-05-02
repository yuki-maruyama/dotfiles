#!/bin/bash

set -euo pipefail

DRY_RUN=false
FORCE=false
INSTALL_PACKAGES=true

usage() {
	cat <<'EOF'
Usage: ./init.sh [--dry-run] [--force] [--no-install]

Options:
  --dry-run     Print actions without changing files.
  --force       Replace existing non-symlink files instead of backing them up.
  --no-install  Skip package installation and only create symlinks.
EOF
}

while [ "$#" -gt 0 ]; do
	case "$1" in
		--dry-run) DRY_RUN=true ;;
		--force) FORCE=true ;;
		--no-install) INSTALL_PACKAGES=false ;;
		-h|--help)
			usage
			exit 0
			;;
		*)
			echo "Unknown option: $1" >&2
			usage >&2
			exit 1
			;;
	esac
	shift
done

BASEDIR=$(cd "$(dirname "$0")" && pwd)
cd "$BASEDIR"

run() {
	if [ "$DRY_RUN" = true ]; then
		printf '[dry-run]'
		printf ' %q' "$@"
		printf '\n'
	else
		"$@"
	fi
}

install_packages() {
	case "$(uname -s)" in
		Darwin)
			run "$BASEDIR/.bin/macos.sh"
			;;
		Linux)
			if [ -e /etc/debian_version ]; then
				run "$BASEDIR/.bin/debian.sh"
			else
				echo "Your distro is not supported" >&2
			fi
			;;
		*)
			echo "Your platform is not supported" >&2
			exit 1
			;;
	esac
}

link_file() {
	local source=$1
	local target=$2
	local target_dir
	target_dir=$(dirname "$target")

	run mkdir -p "$target_dir"

	if [ -L "$target" ]; then
		local current_target
		current_target=$(readlink "$target")
		if [ "$current_target" = "$source" ]; then
			echo "Already linked: $target -> $source"
			return
		fi
		run rm "$target"
	elif [ -e "$target" ]; then
		if [ "$FORCE" = true ]; then
			run rm -rf "$target"
		else
			local backup="$target.backup.$(date +%Y%m%d%H%M%S)"
			echo "Backing up existing file: $target -> $backup"
			run mv "$target" "$backup"
		fi
	fi

	run ln -s "$source" "$target"
}

ROOT_SYMLINKS=(
	".zshrc"
)

CONFIG_SYMLINKS=(
	".config/git/config"
	".config/git/ignore"
	".config/starship.toml"
	".config/sheldon/plugins.toml"
	".config/gwq/config.toml"
)

if [ "$INSTALL_PACKAGES" = true ]; then
	install_packages
fi

for f in "${ROOT_SYMLINKS[@]}"; do
	link_file "$BASEDIR/$f" "$HOME/$f"
done

for f in "${CONFIG_SYMLINKS[@]}"; do
	link_file "$BASEDIR/$f" "$HOME/$f"
done
