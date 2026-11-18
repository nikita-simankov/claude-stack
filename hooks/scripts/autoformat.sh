#!/usr/bin/env bash
# PostToolUse(Edit/Write): format the touched file with the project's formatter.
# Formatting only — no lint autofixes (they would strip imports Claude is about to use).
# Never fails the tool call.
set -uo pipefail
source "$(dirname "$0")/lib.sh"

path="$(json_get .tool_input.file_path)"
[[ -n "$path" && -f "$path" ]] || exit 0
root="$(project_dir)"

# find_up <file> <start-dir> — nearest ancestor containing <file>, bounded by root.
find_up() {
  local d="$2"
  while [[ -n "$d" && "$d" != "/" ]]; do
    [[ -e "$d/$1" ]] && { printf '%s' "$d"; return 0; }
    [[ "$d" == "$root" ]] && break
    d="$(dirname "$d")"
  done
  return 1
}

dir="$(dirname "$path")"
case "$path" in
  *.ts|*.tsx|*.js|*.jsx|*.mjs|*.cjs|*.mts|*.cts|*.json|*.jsonc|*.css)
    cfg="$(find_up biome.json "$dir" || find_up biome.jsonc "$dir")" || exit 0
    bin=""
    for d in "$cfg" "$root"; do
      [[ -x "$d/node_modules/.bin/biome" ]] && { bin="$d/node_modules/.bin/biome"; break; }
    done
    [[ -z "$bin" ]] && command -v biome >/dev/null 2>&1 && bin="biome"
    [[ -n "$bin" ]] && (cd "$cfg" && "$bin" format --write --no-errors-on-unmatched "$path" >/dev/null 2>&1)
    ;;
  *.go)
    command -v gofmt >/dev/null 2>&1 && gofmt -w "$path" >/dev/null 2>&1
    ;;
  *.rs)
    command -v rustfmt >/dev/null 2>&1 || exit 0
    edition="2021"
    if crate="$(find_up Cargo.toml "$dir")"; then
      e="$(grep -Eo '^edition[[:space:]]*=[[:space:]]*"[0-9]{4}"' "$crate/Cargo.toml" | grep -Eo '[0-9]{4}' | head -1)"
      [[ -n "$e" ]] && edition="$e"
    fi
    rustfmt --edition "$edition" "$path" >/dev/null 2>&1
    ;;
esac
exit 0
