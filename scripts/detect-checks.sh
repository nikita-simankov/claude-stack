#!/usr/bin/env bash
# detect-checks: print the project's test / typecheck / lint / format commands, from files only.
# Never runs them. Prints "CHECKS: none" when the repo declares nothing.
# Usage: detect-checks.sh [project-dir]
set -uo pipefail
cd "${1:-.}" 2>/dev/null || { echo "CHECKS: none (directory not found)"; exit 0; }

out=()
add() { out+=("$1"); }
has_script() { [[ -f package.json ]] && jq -e --arg s "$1" '.scripts[$s] // empty' package.json >/dev/null 2>&1; }

if [[ -f package.json ]]; then
  pm=npm
  [[ -f pnpm-lock.yaml ]] && pm=pnpm
  [[ -f bun.lockb || -f bun.lock ]] && pm=bun
  [[ -f yarn.lock ]] && pm=yarn
  add "PM: $pm"
  if ls vitest.config.* vite.config.* >/dev/null 2>&1 || jq -e '.devDependencies.vitest // .dependencies.vitest' package.json >/dev/null 2>&1; then
    add "TEST: $pm vitest run <file>   (all: $pm vitest run)"
  elif has_script test; then
    add "TEST: $pm test"
  fi
  ls playwright.config.* >/dev/null 2>&1 && add "E2E: $pm playwright test <file>"
  if has_script typecheck; then add "TYPECHECK: $pm typecheck"
  elif [[ -f tsconfig.json ]]; then add "TYPECHECK: $pm tsc --noEmit"; fi
  if [[ -f biome.json || -f biome.jsonc ]]; then add "LINT: $pm biome check <files>   FORMAT: $pm biome format --write <files>"
  elif has_script lint; then add "LINT: $pm lint"; fi
  ls drizzle.config.* >/dev/null 2>&1 && add "MIGRATIONS: $pm drizzle-kit generate (review SQL; never edit applied migrations)"
fi
if [[ -f go.mod ]]; then
  add "TEST: go test ./... -race   (one: go test ./<pkg> -run <TestName>)"
  add "VET: go vet ./..."
  [[ -f .golangci.yml || -f .golangci.yaml ]] && add "LINT: golangci-lint run"
fi
if [[ -f Cargo.toml ]]; then
  add "TEST: cargo test   (one: cargo test <name>)"
  add "LINT: cargo clippy --all-targets -- -D warnings   FORMAT: cargo fmt"
fi
[[ -f buf.yaml || -f buf.gen.yaml ]] && add "PROTO: buf lint && buf generate"
[[ -f compose.yaml || -f compose.yml || -f docker-compose.yml || -f docker-compose.yaml ]] && add "SERVICES: docker compose up -d <svc>"

if ((${#out[@]} == 0)); then echo "CHECKS: none"; else printf '%s\n' "${out[@]}"; fi
