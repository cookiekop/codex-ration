#!/usr/bin/env bash
set -euo pipefail

install_herdr=true
case "${1:-}" in
  --without-herdr) install_herdr=false; shift ;;
  '') ;;
  *) printf 'Usage: %s [--without-herdr]\n' "$0" >&2; exit 1 ;;
esac
[[ $# -eq 0 ]] || { printf 'Unexpected arguments\n' >&2; exit 1; }

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

[[ "$install_herdr" == true ]] || exit 0

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

# SSH commands may read .bashrc and return before its interactive setup.
printf -v path_line 'export PATH=%q:"$PATH"' "$herdr_install_dir"
for profile in "$HOME/.profile" "$HOME/.bashrc"; do
  if [[ -f "$profile" ]] && grep -Fxq -- "$path_line" "$profile"; then continue; fi
  if [[ -e "$profile" || -L "$profile" ]]; then
    cp -a -- "$profile" "$profile.backup-$(date +%Y%m%d-%H%M%S)-$$"
  fi
  temporary="$(mktemp "${profile}.XXXXXX")"
  { printf '# Herdr user commands\n%s\n' "$path_line"; [[ ! -f "$profile" ]] || cat -- "$profile"; } > "$temporary"
  [[ ! -f "$profile" ]] || chmod --reference="$profile" "$temporary"
  mv -- "$temporary" "$profile"
done
