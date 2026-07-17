#!/usr/bin/env bash
set -euo pipefail

script_dir="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)"
repo_root="$(cd -- "$script_dir/.." && pwd)"
build_script="$repo_root/scripts/build-agents.sh"
source_file="$repo_root/dotfile/AGENTS.md"
codex_home="${CODEX_HOME:-$HOME/.codex}"
destination="$codex_home/AGENTS.md"
skills_destination="$codex_home/skills"
skill_installer="$skills_destination/.system/skill-installer/scripts/install-skill-from-github.py"

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

skill_paths=()
for skill_name in grill-me grilling; do
  if [[ ! -d "$skills_destination/$skill_name" ]]; then
    skill_paths+=("skills/productivity/$skill_name")
  fi
done

if [[ "${#skill_paths[@]}" -gt 0 ]]; then
  if ! command -v uv >/dev/null 2>&1; then
    printf 'uv is required to install Codex skills. Install uv and rerun this script.\n' >&2
    exit 1
  fi
  if [[ ! -f "$skill_installer" ]]; then
    printf "Codex's built-in skill installer was not found at %s.\n" "$skill_installer" >&2
    exit 1
  fi

  uv run --no-project python "$skill_installer" \
    --repo mattpocock/skills --path "${skill_paths[@]}" --dest "$skills_destination"
else
  printf 'Codex skills already installed: grill-me, grilling\n'
fi
