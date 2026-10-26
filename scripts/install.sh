#!/usr/bin/env bash
set -euo pipefail

script_dir="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)"
repo_root="$(cd -- "$script_dir/.." && pwd)"
build_script="$repo_root/scripts/build-agents.sh"
source_file="$repo_root/dotfile/AGENTS.md"
codex_home="${CODEX_HOME:-$HOME/.codex}"
destination="$codex_home/AGENTS.md"
skills_destination="$codex_home/skills"
skills_source="$repo_root/thirdparties/skills/skills/productivity"
for skill_name in grill-me grilling; do
  [[ -f "$skills_source/$skill_name/SKILL.md" ]] || {
    printf 'Initialize pinned skills: git submodule update --init --recursive\n' >&2
    exit 1
  }
done

install_symlink() {
  local source_file="$1" destination="$2"
  local current_target backup
  mkdir -p -- "$(dirname -- "$destination")"

  if [[ -L "$destination" ]]; then
    current_target="$(readlink "$destination")"
    if [[ "$current_target" != /* ]]; then
      current_target="$(dirname -- "$destination")/$current_target"
    fi
    if [[ "$current_target" == "$source_file" || "$current_target" -ef "$source_file" ]]; then
      printf 'Symlink already current: %s\n' "$destination"
      return
    fi
  fi

  if [[ -e "$destination" || -L "$destination" ]]; then
    backup="$destination.backup-$(date +%Y%m%d-%H%M%S)-$$"
    mv -- "$destination" "$backup"
    printf 'Backed up %s to %s\n' "$destination" "$backup"
  fi
  ln -s -- "$source_file" "$destination"
  printf 'Linked %s -> %s\n' "$destination" "$source_file"
}

"$build_script"
install_symlink "$source_file" "$destination"

for skill_name in grill-me grilling; do
  if [[ ! -e "$skills_destination/$skill_name" && ! -L "$skills_destination/$skill_name" ]]; then
    mkdir -p "$skills_destination"
    cp -a -- "$skills_source/$skill_name" "$skills_destination/$skill_name"
    printf 'Installed pinned skill: %s\n' "$skill_name"
  fi
done

herdr_install_dir="${HERDR_INSTALL_DIR:-$HOME/.local/bin}"
if command -v herdr >/dev/null 2>&1 || [[ -x "$herdr_install_dir/herdr" ]]; then
  printf 'Herdr already installed.\n'
else
  if ! command -v curl >/dev/null 2>&1; then
    printf 'curl is required to install Herdr. Install curl and rerun this script.\n' >&2
    exit 1
  fi
  herdr_installer="$(mktemp)"
  trap 'rm -f -- "$herdr_installer"' EXIT
  curl -fsSL https://herdr.dev/install.sh -o "$herdr_installer"
  sh "$herdr_installer"
fi

install_symlink "$repo_root/dotfile/herdr/config.toml" "$HOME/.config/herdr/config.toml"
