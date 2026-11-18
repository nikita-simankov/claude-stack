---
name: tdd
description: Run one strict TDD cycle (RED → stop for review → GREEN → REFACTOR) for the next task in a tasks.md, or for a described behaviour or bug. Use when implementing any task from a spec, fixing a bug with a reproducing test, or when the user says "tdd", "следующая задача", "next task", "давай реализуем T3".
argument-hint: "[task id, e.g. T3] or <behaviour to implement>"
---

# tdd

One cycle per invocation. Strict. The phase is stored in `.claude/tdd-phase` in the project root; the `guard-tests` hook reads it and blocks edits to test files while the phase is `green`.

## 0. Pick the task
- Find the active `docs/specs/*/tasks.md`; take the given task id or the first `[ ]`/`[~]` task. Mark it `[~]`.
- No tasks file and no description → ask what behaviour to implement.
- Detect the test command from the project (see `conventions`): `pnpm vitest run <file>` / `pnpm test`, `go test ./pkg/... -run <Name>`, `cargo test <name>`.

## 1. RED
```bash
mkdir -p .claude && echo red > .claude/tdd-phase
```
- Write the test(s) for this task's test cases only. Use the project's existing test style, fixtures and helpers.
- Run them. They must **fail**, and fail for the right reason (assertion on the missing behaviour — not a syntax error, import error or missing fixture). Fix the test until it fails correctly.
- **STOP.** Show the test code and the failure output (trimmed). Ask: "Тест ок? Иду в GREEN?" Do not write production code yet.

## 2. GREEN (after approval)
```bash
echo green > .claude/tdd-phase
```
- Write the minimum production code that makes the tests pass. No extra features, no speculative generality.
- Test files are frozen. If you become convinced the test is wrong, stop and explain; do not edit it, do not work around it.
- Run the task's tests until green. Two failed attempts → escalate per CLAUDE.md (`debugger` subagent).

## 3. REFACTOR
```bash
echo refactor > .claude/tdd-phase
```
- Remove duplication, improve names, match conventions. Behaviour unchanged; tests may be tidied but not weakened.
- Run: the task's tests, the surrounding package/module suite, typecheck and lint (`pnpm tsc --noEmit`, `pnpm biome check`, `go vet ./...`, `cargo clippy`). All green.

## 4. Close
```bash
rm -f .claude/tdd-phase
```
- Tick the task `[x]` in `tasks.md`.
- Report in ≤5 lines: task, files changed, commands run with results, anything left out.
- Stop. Do not start the next task without the user.

## Notes
- Rust unit tests inside `#[cfg(test)] mod tests` live in the production file, so the hook cannot freeze them; the rule still applies.
- Bug fix: the RED test reproduces the bug exactly as reported.
