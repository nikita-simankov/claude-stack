#!/usr/bin/env bash
# PreToolUse: keep secrets and catastrophic commands out of reach.
set -uo pipefail
source "$(dirname "$0")/lib.sh"

tool="$(json_get .tool_name)"

is_secret_path() {
  local base
  base="$(basename "$1")"
  case "$base" in
    .env.example|.env.sample|.env.template|.env.dist) return 1 ;;
    .env|.env.*|*.pem|*.key|*.p12|*.pfx|*.keystore|id_rsa*|id_ed25519*|id_ecdsa*|credentials.json|service-account*.json|.pgpass|.netrc) return 0 ;;
  esac
  return 1
}

if [[ "$tool" == "Bash" ]]; then
  cmd="$(json_get .tool_input.command)"
  [[ -z "$cmd" ]] && exit 0

  # Secret files referenced from the shell.
  if printf '%s' "$cmd" | grep -Eq '(^|[[:space:]/"'"'"'=<])\.env(\.[A-Za-z0-9_-]+)?([[:space:]"'"'"';|&)>]|$)' \
     && ! printf '%s' "$cmd" | grep -Eq '\.env\.(example|sample|template|dist)'; then
    block "command touches a .env file. Ask the user for the specific non-secret value you need."
  fi
  if printf '%s' "$cmd" | grep -Eq '(id_rsa|id_ed25519|id_ecdsa|\.pem([[:space:]]|$)|\.p12|\.pfx|\.pgpass|\.netrc|credentials\.json)'; then
    block "command touches a key or credentials file."
  fi
  if printf '%s' "$cmd" | grep -Eq '(^|[^A-Za-z_])(printenv|env)([[:space:]]*$|[[:space:]]*[|>])'; then
    block "dumping the whole environment can leak secrets. Read only the specific variable you need."
  fi

  # Catastrophic or remote-code commands.
  if printf '%s' "$cmd" | grep -Eq 'rm[[:space:]]+(-[A-Za-z]*[rR][A-Za-z]*[[:space:]]+(-[A-Za-z]+[[:space:]]+)*|--recursive[[:space:]]+)(/|~|\$HOME|/\*|\*|\.\.?/?)([[:space:]]|$)'; then
    block "recursive delete of /, ~, \$HOME, . or *. Delete specific paths instead."
  fi
  if printf '%s' "$cmd" | grep -Eq '(curl|wget)[^|]*\|[[:space:]]*(sudo[[:space:]]+)?(ba|z|da)?sh'; then
    block "piping a download into a shell. Download, inspect, then run."
  fi
  if printf '%s' "$cmd" | grep -Eqi '(drop[[:space:]]+(database|schema|table)|truncate[[:space:]]+(table[[:space:]]+)?[a-z_"]|dropdb[[:space:]])'; then
    block "destructive SQL (DROP/TRUNCATE). Give the statement to the user to run."
  fi
  if printf '%s' "$cmd" | grep -Eq '(mkfs|dd[[:space:]]+[^|]*of=/dev/|chmod[[:space:]]+-R[[:space:]]+777|>[[:space:]]*/dev/sd)'; then
    block "system-destructive command."
  fi
  exit 0
fi

# File tools.
path="$(json_get .tool_input.file_path)"
[[ -z "$path" ]] && path="$(json_get .tool_input.notebook_path)"
[[ -z "$path" ]] && exit 0
if is_secret_path "$path"; then
  block "$tool on secret file $(basename "$path"). Use .env.example for structure; ask the user for values."
fi
exit 0
