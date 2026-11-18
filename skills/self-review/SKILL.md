---
name: self-review
description: Review your own uncommitted diff before handing work over. Use after finishing a task or feature, before commit-msg, or when the user says "self-review", "проверь себя", "ревью диффа". For an independent second opinion use the code-reviewer subagent instead.
---

# self-review

1. Get the diff: `git diff` and `git diff --stat` (plus `git status` for untracked files). Read every hunk.
2. Check, in this order, and fix what you find:
   - **Correctness**: does it do what the spec/task says? Edge cases from the spec covered? Error paths?
   - **Tests**: every behaviour change has a test; no test was weakened; no `.only`/`.skip`/`t.Skip`/`#[ignore]` left.
   - **Leftovers**: debug logs, `console.log`, `dbg!`, `fmt.Println`, commented-out code, TODOs without context, stray files.
   - **Security**: input validation (zod/tRPC input, gRPC), authz checks on new procedures/endpoints, SQL built by string concat, secrets in code or logs.
   - **Data**: migration present and reversible where possible; indexes for new queries; `timestamptz`; nullability matches the code.
   - **Conventions**: matches `conventions` skill and surrounding code; naming; no new dependency without reason.
   - **Scope**: nothing unrelated to the task slipped in.
3. Run the checks: tests for touched packages, typecheck, lint/format.
4. Report:
```
Дифф: <N files, +X/-Y>
Исправил: <list or "ничего">
Проверено: <commands → result>
Риски/вопросы: <list or "нет">
```
For large or risky diffs, also run the `code-reviewer` subagent and report its findings.
