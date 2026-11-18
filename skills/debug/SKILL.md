---
name: debug
description: Systematic debugging to the root cause. Use when a test fails unexpectedly, a bug is reported, behaviour differs between environments, or the user says "debug", "почему не работает", "баг", "падает", "разберись". Reproduce, hypothesize, prove, fix with a regression test.
argument-hint: "<symptom, error message or failing test>"
---

# debug

No guess-and-patch. Every change is justified by evidence.

1. **Reproduce.** Get a deterministic repro: a failing test (preferred), a command, or exact steps. Capture the full error and stack trace. Cannot reproduce → gather facts (logs, env, versions, inputs) before touching code.
2. **Localize.** Narrow down: read the stack trace top-down to the first frame in our code; check recent changes (`git log -p -- <path>`, `git diff`); bisect inputs; add temporary logging.
3. **Hypotheses.** Write 2-3 candidate causes, most likely first, each with the experiment that would confirm or kill it. Run the cheapest decisive experiment first.
4. **Root cause.** State it in one sentence: *what* is wrong, *why* it happens, *why* it was not caught. A symptom ("value is undefined") is not a root cause.
5. **Fix via TDD.** Regression test that fails on the bug → minimal fix → test passes → related suite passes. Use the `tdd` skill flow when the user is around for the RED checkpoint.
6. **Clean up** temporary logging. Check for the same bug pattern elsewhere (`grep`) and report places, do not silently fix them all.

## Escalation
- Two hypotheses killed and no new lead → hand off to the `debugger` subagent with: symptom, repro, stack trace, hypotheses tried and their results, relevant files.
- Debugger fails → `council` skill.

## Stack hints
- TS: check `await` missing, React Query cache keys/staleness, tRPC input schema (zod) mismatch, server/client component boundary in Next.js, env vars differing between edge/node runtime.
- Drizzle/Postgres: transaction scope, `NULL` semantics, timezone (`timestamp` vs `timestamptz`), migration not applied.
- Go: nil interface vs nil pointer, goroutine leaks, `context` cancellation, data races (`go test -race`).
- Rust: lifetimes vs ownership redesign, `unwrap` in async tasks, blocking calls inside tokio runtime.
- Redis: TTL, key collisions, serialization mismatch. Docker: stale image, missing env, network names.

## Report
```
Причина: <one sentence>
Доказательство: <experiment/output>
Фикс: <file:line> + регрессионный тест <test name>
Проверено: <commands>
```
