#!/usr/bin/env bash
set -euo pipefail

script_dir="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)"
repo_root="$(cd -- "$script_dir/.." && pwd)"
build_script="$repo_root/scripts/build-agents.sh"
source_file="$repo_root/dotfile/AGENTS.md"
codex_home="${CODEX_HOME:-$HOME/.codex}"
destination="$codex_home/AGENTS.md"

"$build_script"
mkdir -p "$codex_home"

expected_target="$(cd -- "$(dirname -- "$source_file")" && pwd)/$(basename -- "$source_file")"
needs_link=1

if [[ -L "$destination" ]]; then
  current_target="$(readlink "$destination")"
  if [[ "$current_target" != /* ]]; then
    current_target="$(cd -- "$(dirname -- "$destination")" && cd -- "$(dirname -- "$current_target")" && pwd)/$(basename -- "$current_target")"
  fi
  if [[ "$current_target" == "$expected_target" ]]; then
    needs_link=0
  fi
fi

if [[ "$needs_link" -eq 1 && -e "$destination" || "$needs_link" -eq 1 && -L "$destination" ]]; then
  timestamp="$(date +%Y%m%d-%H%M%S)"
  backup="$destination.backup-$timestamp"
  mv -- "$destination" "$backup"
  printf 'Backed up existing AGENTS.md to %s\n' "$backup"
fi

if [[ "$needs_link" -eq 1 ]]; then
  ln -s -- "$source_file" "$destination"
  printf 'Linked %s -> %s\n' "$destination" "$source_file"
else
  printf 'Symlink already current: %s\n' "$destination"
fi
