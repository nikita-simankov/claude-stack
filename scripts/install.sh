#!/usr/bin/env bash
# claude-stack installer.
#   scripts/install.sh                 global: CLAUDE.md symlink + settings merge (plugin, permissions)
#   scripts/install.sh --project DIR   also scaffold project files into DIR (CLAUDE.md, .mcp.json, .gitignore)
#   scripts/install.sh --uninstall     remove the global CLAUDE.md symlink (settings left as is)
set -euo pipefail

REPO="$(cd "$(dirname "$0")/.." && pwd)"
CLAUDE_HOME="${CLAUDE_CONFIG_DIR:-$HOME/.claude}"
STAMP="$(date +%Y%m%d-%H%M%S)"
PROJECT=""
UNINSTALL=0

while [[ $# -gt 0 ]]; do
  case "$1" in
    --project) PROJECT="${2:?--project needs a directory}"; shift 2 ;;
    --uninstall) UNINSTALL=1; shift ;;
    -h|--help) sed -n '2,6p' "$0"; exit 0 ;;
    *) echo "unknown option: $1" >&2; exit 1 ;;
  esac
done

say() { printf '  %s\n' "$*"; }
need() { command -v "$1" >/dev/null 2>&1 || { echo "error: '$1' is required" >&2; exit 1; }; }

link_claude_md() {
  local target="$CLAUDE_HOME/CLAUDE.md"
  mkdir -p "$CLAUDE_HOME"
  if [[ -L "$target" && "$(readlink "$target")" == "$REPO/CLAUDE.md" ]]; then
    say "CLAUDE.md already linked"
    return
  fi
  if [[ -e "$target" || -L "$target" ]]; then
    mv "$target" "$target.bak-$STAMP"
    say "backed up existing CLAUDE.md → CLAUDE.md.bak-$STAMP"
  fi
  ln -s "$REPO/CLAUDE.md" "$target"
  say "linked $target → $REPO/CLAUDE.md (git pull updates it)"
}

merge_settings() {
  need jq
  local target="$CLAUDE_HOME/settings.json" tmp
  [[ -f "$target" ]] || echo '{}' >"$target"
  cp "$target" "$target.bak-$STAMP"
  tmp="$(mktemp)"
  # Deep merge: existing values win for scalars, arrays are unioned, objects merged.
  jq -s '
    def m($a; $b):
      if ($a|type) == "object" and ($b|type) == "object" then
        reduce (($a + $b) | keys_unsorted[]) as $k ({};
          .[$k] = (if ($a|has($k)) and ($b|has($k)) then m($a[$k]; $b[$k])
                   elif ($a|has($k)) then $a[$k] else $b[$k] end))
      elif ($a|type) == "array" and ($b|type) == "array" then ($a + ($b - $a))
      else $a end;
    m(.[0]; .[1])
  ' "$target" "$REPO/templates/settings.json" >"$tmp"
  mv "$tmp" "$target"
  say "merged templates/settings.json into $target (backup: settings.json.bak-$STAMP)"
}

scaffold_project() {
  local dir="$1"
  [[ -d "$dir" ]] || { echo "error: $dir is not a directory" >&2; exit 1; }
  if [[ -e "$dir/CLAUDE.md" ]]; then say "project CLAUDE.md exists, skipped"
  else cp "$REPO/templates/project-CLAUDE.md" "$dir/CLAUDE.md"; say "created $dir/CLAUDE.md — fill in the placeholders"; fi
  if [[ -e "$dir/.mcp.json" ]]; then say ".mcp.json exists, skipped (template: templates/mcp.json)"
  else cp "$REPO/templates/mcp.json" "$dir/.mcp.json"; say "created $dir/.mcp.json — needs DATABASE_URI_READONLY and GITHUB_PAT in your env"; fi
  touch "$dir/.gitignore"
  if grep -q 'claude-stack' "$dir/.gitignore"; then say ".gitignore already has claude-stack entries"
  else printf '\n' >>"$dir/.gitignore"; cat "$REPO/templates/gitignore-snippet" >>"$dir/.gitignore"; say "appended claude-stack entries to .gitignore"; fi
}

if ((UNINSTALL)); then
  t="$CLAUDE_HOME/CLAUDE.md"
  if [[ -L "$t" && "$(readlink "$t")" == "$REPO/CLAUDE.md" ]]; then rm "$t"; say "removed CLAUDE.md symlink"
  else say "CLAUDE.md is not linked to this repo, nothing to do"; fi
  say "settings.json untouched; backups are in $CLAUDE_HOME/settings.json.bak-*"
  say "to remove the plugin: /plugin uninstall stack@claude-stack"
  exit 0
fi

echo "claude-stack → $CLAUDE_HOME"
link_claude_md
merge_settings
[[ -n "$PROJECT" ]] && { echo "project → $PROJECT"; scaffold_project "$PROJECT"; }
cat <<MSG

Done. Restart Claude Code. The plugin 'stack@claude-stack' is enabled via settings;
if it is not picked up, run inside Claude Code:
  /plugin marketplace add nikita-simankov/claude-stack
  /plugin install stack@claude-stack
MSG
