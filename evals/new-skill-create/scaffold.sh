#!/usr/bin/env bash
set -euo pipefail
git -C /home/user/claude-stack archive HEAD | tar -x
rm -rf evals
git init -q && git config user.email d@e && git config user.name d && git add -A && git commit -qm base
