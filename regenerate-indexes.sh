#!/usr/bin/env bash
set -euo pipefail

# Regenerate README.md indexes for every top-level directory.
# - Sorts entries naturally and case-insensitively.
# - Percent-encodes common Markdown link characters.
# - Validates every generated local link against the source file.
# Run from the repository root: ./regenerate-indexes.sh

failures=0

encode_path() {
  local s="$1"
  s="${s//%/%25}"
  s="${s// /%20}"
  s="${s//#/%23}"
  s="${s//\?/%3F}"
  printf '%s' "$s"
}

for dir in */; do
  dir="${dir%/}"
  readme="$dir/README.md"
  tmp="$(mktemp)"

  printf '# %s Index\n\n' "$dir" > "$tmp"

  # Version sort gives a useful order such as 1, 2, 10 rather than 1, 10, 2.
  # -f makes alphabetic sorting case-insensitive.
  while IFS= read -r file; do
    name="${file##*/}"
    [[ "$name" == "README.md" ]] && continue

    target="$(encode_path "$name")"
    printf -- '- [%s](./%s)\n' "$name" "$target" >> "$tmp"

    # Validate the generated link target before replacing README.md.
    if [[ ! -f "$dir/$name" ]]; then
      printf 'ERROR: broken generated link: %s -> %s\n' "$readme" "$dir/$name" >&2
      failures=$((failures + 1))
    fi
  done < <(find "$dir" -mindepth 1 -maxdepth 1 -type f ! -name 'README.md' -print | LC_ALL=C sort -fV)

  mv "$tmp" "$readme"
  printf 'Updated %s\n' "$readme"
done

if (( failures > 0 )); then
  printf 'Validation failed: %d broken link(s) found.\n' "$failures" >&2
  exit 1
fi

printf 'Validation passed: all generated links point to existing files.\n'
