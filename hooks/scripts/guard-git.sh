#!/usr/bin/env bash
# PreToolUse(Bash): the user owns git. Block every git command that writes
# to the repository, index, refs, stash, config or remote. Read-only git is allowed.
# Escape hatch for a specific repo: set STACK_ALLOW_GIT=1 in that project's settings env.
set -uo pipefail
export FAIL_CLOSED=1
source "$(dirname "$0")/lib.sh"

[[ "${STACK_ALLOW_GIT:-0}" == "1" ]] && exit 0

cmd="$(json_get .tool_input.command)"
[[ -z "$cmd" || "$cmd" != *git* ]] && exit 0

# Normalise: drop quotes, turn shell separators into newlines.
norm="$(printf '%s' "$cmd" | tr -d "\"'\`" | sed -E 's/(\&\&|\|\||;|\||\$\(|\(|\)|\{|\})/\n/g')"

deny_sub="add am apply checkout cherry-pick clean commit filter-branch filter-repo gc merge mv notes prune pull push rebase replace reset restore revert rm switch update-index update-ref worktree bisect submodule"

while IFS= read -r seg; do
  read -ra t <<<"$seg"
  n=${#t[@]}
  for ((i = 0; i < n; i++)); do
    [[ "${t[i]}" == "git" || "${t[i]}" == */git ]] || continue
    # Only at command position: start of segment, after a wrapper, or after VAR=val / sh -c.
    if ((i > 0)); then
      prev="${t[i - 1]}"
      [[ "$prev" =~ ^(sudo|xargs|time|nice|nohup|command|exec|env|-c|then|do|else)$ || "$prev" =~ ^[A-Za-z_][A-Za-z0-9_]*=.*$ ]] || continue
    fi
    # Skip git global options to reach the subcommand.
    j=$((i + 1))
    while ((j < n)); do
      case "${t[j]}" in
        -C|-c|--git-dir|--work-tree|--namespace) j=$((j + 2)) ;;
        -*) j=$((j + 1)) ;;
        *) break ;;
      esac
    done
    ((j < n)) || continue
    sub="${t[j]}"
    args=("${t[@]:j+1}")
    reason=""
    if [[ " $deny_sub " == *" $sub "* ]]; then
      reason="git $sub"
    else
      case "$sub" in
        stash)
          [[ "${args[0]:-push}" =~ ^(list|show)$ ]] || reason="git stash ${args[0]:-}" ;;
        tag)
          for a in "${args[@]}"; do
            [[ "$a" =~ ^(-l|--list|-n[0-9]*|--contains|--points-at|--sort=.*|--format=.*)$ ]] && continue
            reason="git tag (create/delete)"; break
          done ;;
        branch)
          for a in "${args[@]}"; do
            [[ "$a" =~ ^(-a|-r|-v|-vv|--all|--remotes|--list|-l|--show-current|--merged|--no-merged|--contains|--sort=.*|--format=.*|--color.*|--no-color)$ ]] && continue
            reason="git branch (create/delete/rename)"; break
          done ;;
        config)
          ro=0
          for a in "${args[@]}"; do
            [[ "$a" =~ ^(--get|--get-all|--get-regexp|--list|-l|--show-origin|--show-scope)$ ]] && ro=1
          done
          ((ro)) || reason="git config (write)" ;;
        remote)
          [[ -z "${args[0]:-}" || "${args[0]}" =~ ^(-v|--verbose|show|get-url)$ ]] || reason="git remote ${args[0]}" ;;
      esac
    fi
    [[ -n "$reason" ]] && block "$reason — the user runs git themselves. Prepare the change and use the commit-msg skill to hand over the exact commands."
  done
done <<<"$norm"

exit 0
