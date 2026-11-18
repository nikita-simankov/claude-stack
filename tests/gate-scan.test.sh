#!/usr/bin/env bash
# Tests for scripts/gate-scan.sh and scripts/detect-checks.sh on throwaway git repos.
set -uo pipefail
ROOT="$(cd "$(dirname "$0")/.." && pwd)"
SCAN="$ROOT/scripts/gate-scan.sh"
DETECT="$ROOT/scripts/detect-checks.sh"
T="$(mktemp -d)"; trap 'rm -rf "$T"' EXIT
pass=0; failed=0
ok()   { pass=$((pass + 1)); }
fail() { failed=$((failed + 1)); printf '  FAIL  %s\n' "$1"; }
expect_has() { grep -qE "$2" <<<"$1" && ok || fail "$3 (missing /$2/)"; }
expect_not() { grep -qE "$2" <<<"$1" && fail "$3 (unexpected /$2/)" || ok; }

repo() { rm -rf "$T/r"; mkdir -p "$T/r" && cd "$T/r" && git init -q && git config user.email t@t && git config user.name t; }

# --- dirty diff: every pattern present ---
repo
mkdir -p src svc docs/specs/billing .github/workflows src/__snapshots__
cat > src/price.ts <<'EOF'
export function price(x: number) {
  return x;
}
EOF
cat > src/price.test.ts <<'EOF'
it("keeps price", () => {
  expect(price(1)).toBe(1);
});
it("rejects negative", () => {
  expect(() => price(-1)).toThrow();
});
EOF
printf 'exports[`a`] = `1`;\n' > src/__snapshots__/view.test.ts.snap
printf -- '- AC1: Given a negative price, when computed, then it throws\n' > docs/specs/billing/spec.md
printf 'jobs:\n  t:\n    steps:\n      - run: pnpm test\n' > .github/workflows/ci.yml
git add -A && git commit -qm base

cat > src/price.ts <<'EOF'
export function price(x: number) {
  // @ts-ignore
  if (process.env.NODE_ENV === "test") return x;
  try { risky(); } catch (e) {}
  throw new Error("not implemented");
}
EOF
cat > src/price.test.ts <<'EOF'
it.skip("keeps price", () => {
  expect(price(1)).toBe(1);
}, { timeout: 30000 });
EOF
printf 'exports[`a`] = `2`;\n' > src/__snapshots__/view.test.ts.snap
printf -- '- AC1: Given a negative price, when computed, then it returns 0\n' > docs/specs/billing/spec.md
printf 'jobs:\n  t:\n    continue-on-error: true\n    steps:\n      - run: pnpm test\n' > .github/workflows/ci.yml
printf 'package svc\n\nfunc Run() error {\n\tpanic("not implemented")\n}\n' > svc/run.go
out="$(bash "$SCAN")"
expect_has "$out" '^RH-1 +src/price.test.ts:1 +added' "RH-1 skip added"
expect_has "$out" '^RH-1 +src/price.test.ts:[0-9]+ +removed .*it\("rejects negative' "RH-1 test removed"
expect_has "$out" '^RH-3\? +src/__snapshots__/view.test.ts.snap' "RH-3 snapshot whose owner view.test.ts is not in diff"
expect_has "$out" '^RH-4 +src/price.ts:5' "RH-4 not implemented"
expect_has "$out" '^RH-4 +svc/run.go:4' "RH-4 go panic (untracked file)"
expect_has "$out" '^RH-10 +docs/specs/billing/spec.md' "RH-10 AC edited"
expect_has "$out" '^RH-12 +src/price.ts:3' "RH-12 env sniffing"
expect_has "$out" '^RH-13 +src/price.ts:2' "RH-13 ts-ignore"
expect_has "$out" '^RH-14 +.github/workflows/ci.yml' "RH-14 continue-on-error"
expect_has "$out" '^RH-15\? +src/price.test.ts' "RH-15 timeout"
expect_has "$out" '^RH-16 +src/price.ts:4' "RH-16 swallowed"
expect_has "$out" '^GATE-SCAN: [0-9]+ hit' "summary line"

# Snapshot owner logic, isolated case.
# Re-check with an owner-less snapshot change.
repo
mkdir -p src/__snapshots__ && printf 'a\n' > src/__snapshots__/card.test.ts.snap && printf 'it("x",()=>{})\n' > src/card.test.ts
git add -A && git commit -qm base && printf 'b\n' > src/__snapshots__/card.test.ts.snap
out="$(bash "$SCAN")"
expect_has "$out" '^RH-3\? +src/__snapshots__/card.test.ts.snap' "RH-3 snapshot without owning test"

# --- clean diff: ordinary TDD change, no hits ---
repo
mkdir -p src && printf 'export const a = 1;\n' > src/a.ts && printf 'it("a", () => { expect(a).toBe(1); });\n' > src/a.test.ts
git add -A && git commit -qm base
printf 'export const a = 1;\nexport function b(x: number) {\n  if (x < 0) throw new RangeError("negative");\n  return x * 2;\n}\n' > src/a.ts
printf 'it("a", () => { expect(a).toBe(1); });\nit("b rejects negative", () => { expect(() => b(-1)).toThrow(RangeError); });\n' > src/a.test.ts
out="$(bash "$SCAN")"
expect_has "$out" '^GATE-SCAN: none$' "clean diff has no hits"

# --- base ref argument ---
git add -A && git commit -qm feature && printf 'it.only("x", () => {});\n' >> src/a.test.ts && git commit -qam more
out="$(bash "$SCAN" HEAD~2)"
expect_has "$out" '^RH-1 +src/a.test.ts' "scan against base ref"

# --- not a repo ---
cd "$T" && mkdir -p plain && cd plain || exit 1
bash "$SCAN" >/dev/null 2>&1; [[ $? -eq 1 ]] && ok || fail "non-repo exits 1"

# --- detect-checks ---
mkdir -p "$T/ts" && cd "$T/ts" || exit 1
printf '{"scripts":{"test":"vitest"},"devDependencies":{"vitest":"1"}}' > package.json
touch pnpm-lock.yaml biome.json tsconfig.json
out="$(bash "$DETECT")"
expect_has "$out" '^PM: pnpm$' "detect pnpm"
expect_has "$out" '^TEST: pnpm vitest run' "detect vitest"
expect_has "$out" '^TYPECHECK: pnpm tsc --noEmit' "detect tsc"
expect_has "$out" '^LINT: pnpm biome check' "detect biome"
mkdir -p "$T/go" && cd "$T/go" || exit 1; printf 'module x\n' > go.mod
out="$(bash "$DETECT")"
expect_has "$out" '^TEST: go test ./\.\.\. -race' "detect go"
expect_not "$out" '^PM:' "go project has no PM"
mkdir -p "$T/empty"; out="$(bash "$DETECT" "$T/empty")"
expect_has "$out" '^CHECKS: none$' "empty project"

printf '  gate-scan/detect-checks: %d passed, %d failed\n' "$pass" "$failed"
((failed == 0))
