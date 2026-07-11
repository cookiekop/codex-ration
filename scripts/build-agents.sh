#!/usr/bin/env bash
set -euo pipefail

script_dir="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)"
repo_root="$(cd -- "$script_dir/.." && pwd)"
source_dir="$repo_root/src"
output_dir="$repo_root/dotfile"
output_file="$output_dir/AGENTS.md"

if [[ ! -d "$source_dir" ]]; then
  printf 'Source directory not found: %s\n' "$source_dir" >&2
  exit 1
fi

shopt -s nullglob
modules=("$source_dir"/*.md)
shopt -u nullglob
if [[ "${#modules[@]}" -eq 0 ]]; then
  printf 'No AGENTS.md modules found in %s\n' "$source_dir" >&2
  exit 1
fi
mapfile -t modules < <(printf '%s\n' "${modules[@]}" | sort)

mkdir -p "$output_dir"

{
  for module in "${modules[@]}"; do
    sed -e '${/^$/d;}' "$module"
    printf '\n\n'
  done
} > "$output_file"

printf 'Generated %s\n' "$output_file"
