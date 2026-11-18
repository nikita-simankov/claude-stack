---
name: catchup
description: Restore working context at the start of a session or after a break. Use when the user says "catchup", "где мы остановились", "что тут происходит", "продолжаем", or when resuming work on a repo with uncommitted changes, HANDOFF.md or an in-progress tasks.md.
---

# catchup

Build a picture of the current state, fast, without changing anything.

1. `HANDOFF.md` in the project root → read it first; it is the previous session's note to you.
2. Active spec: `docs/specs/*/tasks.md` with `[~]` or unchecked tasks → read that tasks.md and its spec.md.
3. `.claude-stack/tdd-phase` → which TDD phase was interrupted.
4. Git (read-only): `git branch --show-current`, `git status --short`, `git diff --stat`, `git log --oneline -10`. Skim the diff of changed files.
5. Run the tests for the active task to learn the real state (green/red), if cheap.

Report in ≤8 lines:
```
Ветка: ...
Фича/задача: <spec> · <task> · фаза <red|green|refactor|—>
Состояние: <tests green/red, uncommitted files>
Последнее сделанное: ...
Следующий шаг: ...
Неясно: ...
```
Then wait.
