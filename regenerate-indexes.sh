#!/usr/bin/env bash
set -euo pipefail

# Regenerate README.md indexes for every top-level directory.
# Run from the repository root: ./regenerate-indexes.sh

for dir in */; do
  dir="${dir%/}"
  readme="$dir/README.md"
  tmp="$(mktemp)"

  printf '# %s Index\n\n' "$dir" > "$tmp"

  while IFS= read -r -d '' file; do
    name="${file##*/}"
    [[ "$name" == "README.md" ]] && continue

    # GitHub Markdown links need percent-encoded spaces.
    target="${name// /%20}"
    printf -- '- [%s](./%s)\n' "$name" "$target" >> "$tmp"
  done < <(find "$dir" -mindepth 1 -maxdepth 1 -type f -print0 | sort -z)

  mv "$tmp" "$readme"
  echo "Updated $readme"
done
