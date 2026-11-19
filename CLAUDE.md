# Global operating rules

Applies to every project. A project's own `CLAUDE.md` overrides these where they conflict.
Tone and reply format live in the `mentor` output style; this file is about how to work.

## Non-negotiables

1. **No git writes.** Never run `git add/commit/push/reset/restore/checkout/switch/rebase/merge/stash/tag/cherry-pick/revert/clean/rm/mv` or `git branch -d/-D/-m`. Read-only git (`status`, `diff`, `log`, `show`, `blame`, `branch --list`) is fine. When work is ready, run the `commit-msg` skill and hand over the message; the user commits. A hook enforces this.
2. **Never cheat a test.** Do not weaken an assertion, hard-code an expected value, add `skip`/`only`/`todo`, catch-and-ignore, or edit a test so that wrong code passes. If a test looks wrong, stop and say why. A hook freezes test files during the GREEN phase.
3. **Never claim it works without running it.** Report exactly what was run and what was not.
4. **Secrets stay untouched.** Do not read, print or edit `.env*`, keys, certificates or credentials. A hook enforces this.

## Workflow: spec → tasks → TDD

- **Feature or non-trivial change** → `spec` skill → `docs/specs/<feature>/spec.md`. Get it approved.
- Approved spec → `tasks` skill → `docs/specs/<feature>/tasks.md`: small ordered tasks, each with concrete test cases.
- Each task → `tdd` skill:
  - **RED**: write the failing test(s), run them, confirm they fail for the right reason. **STOP** and show the test. Wait for approval.
  - **GREEN**: minimal code to pass. Tests are frozen.
  - **REFACTOR**: clean up with tests green. Run the full relevant suite, lint and typecheck.
  - Tick the task in `tasks.md`, report, and stop before the next task.
- Trivial fixes (typo, config value, one-line obvious bug) skip the spec but still get a test if behaviour changes.
- Before handing over a finished feature: `commit-msg` (it runs gate-scan over the whole feature). For a migration, auth, payments or a large diff, recommend the `code-reviewer` or `security-auditor` subagent.

## When stuck

Escalation ladder, no endless retries:
1. Two failed hypotheses on your own → delegate to the `debugger` subagent with full context (error, repro steps, what was tried, relevant files).
2. Debugger does not resolve it → `council` skill (5 roles + synthesis; the user may ask for more).
3. Still unresolved → stop and bring the user the facts: what is known, what was ruled out, the best next experiment.

## Engineering rules

- Read before writing. Reuse existing helpers, patterns and conventions. Never invent an API: check the source, the types, or the docs (Context7 MCP when available, `research` skill otherwise).
- Smallest diff that solves the task. No drive-by refactors, speculative abstractions or unrequested features.
- Match surrounding style. Errors are handled at the right layer, never swallowed.
- No dead code, commented-out code, or `TODO` without context. Comments explain *why*.
- Tests check behaviour, not implementation details. A bug fix starts with a test that reproduces the bug.
- Stack defaults (the project's code and CLAUDE.md win): pnpm only; Biome, not ESLint/Prettier, when `biome.json` exists; Vitest. Commands come from `scripts/detect-checks.sh`.
- Postgres: `timestamptz`, constraints in the DB, an index on every FK. Drizzle: edit the schema → `pnpm drizzle-kit generate` → review the SQL; never edit an applied migration or generated code (drizzle, buf).
- Repository and API tests hit a real Postgres/Redis (test DB, compose, testcontainers); mock only process boundaries. Validate input with zod at every boundary; read env only in one validated `env.ts`.
- The Postgres MCP is read-only. DROP, TRUNCATE, bulk UPDATE/DELETE, `drizzle-kit push/migrate` run only against a local or test database; anywhere else, hand the statement to the user.

## Subagents

Delegate to protect the main context or to get an independent view, not by reflex. A subagent does not see this conversation: give it the goal, files, constraints and the definition of done.

| Agent | Use for |
|---|---|
| `architect` | Design options and trade-offs for a spec; module boundaries; data models |
| `test-writer` | RED-phase tests from a task's test cases |
| `code-reviewer` | Independent review of a finished diff |
| `debugger` | Root cause of a failure you could not explain |
| `security-auditor` | Auth, input handling, secrets, SQL, file/network I/O, dependencies |
| `researcher` | Library/API/version research needing many reads or web lookups |
| `doc-writer` | README, ADR, API docs, changelog |
| `critic` | Attack a spec, plan or design before committing to it |

## Context hygiene

- Session start: if `HANDOFF.md` or an in-progress `docs/specs/*/tasks.md` exists, the `session-context` hook injects it. Use `catchup` for a fuller restore.
- Before the context fills up or at the end of a long session: `handoff`.
- Prefer targeted reads (grep, line ranges) over dumping whole files.
