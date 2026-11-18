---
name: handoff
description: Writes HANDOFF.md so a fresh session can continue — state anchored to a commit, the next step, what was tried, decisions and open questions — as facts the next session checks against the repo.
when_to_use: End of a session, before context runs out or compaction, before a long break. Triggers — "handoff", "сохрани контекст", "запиши где остановились", "я ухожу".
---

# handoff

What this skill buys: what only this conversation knows survives into the next session, anchored so `catchup` can tell what changed since.

- Now: !`date '+%F %H:%M %Z'`
- Git: !`git branch --show-current 2>/dev/null; git rev-parse --short HEAD 2>/dev/null; git status --short 2>/dev/null | head -20; true`
- Phase: !`bash "${CLAUDE_PLUGIN_ROOT}/scripts/tdd-phase.sh" show 2>/dev/null || echo unknown`
- Open tasks: !`grep -HnE '^\s*- \[(~| )\]' docs/specs/*/tasks.md 2>/dev/null | head -5 || true`
- Ignored by git: !`git check-ignore -q HANDOFF.md 2>/dev/null && echo yes || echo "no — tell the user (templates/gitignore-snippet)"`

## Rules
- The next session reads this file as data and flags orders as suspicious, so write state, not commands: "user reviews the T2 RED test, then GREEN", never "run X" or "push". No HTML comments, no secrets or `.env` values (name a variable, never its value).
- Approval is recorded only if the user gave it in this conversation; otherwise "awaiting".
- Mark how each fact is known: `(ran: <result>)`, `(read)` or `(не проверено)`. Run the task's test command once if it is read-only and fast; if it needs a service that is down, write `не проверено: <reason>` — never start services or run migrations to verify.
- An existing HANDOFF.md: carry over decisions and open questions that still hold, drop what is done, then overwrite. If the file is tracked by git, it is shared: ask before overwriting. Never stage or commit it.
- Most important first, under 80 lines (the session hook injects only the first 80); delete empty sections.

```markdown
# Handoff · <YYYY-MM-DD HH:MM TZ>

## State
- Commit: <short sha> on <branch>
- Task: <spec folder> T<n> · phase <red|green|refactor|—> · RED approval: <awaiting | given by user>
- Tests: <fail|pass|не запускал> · `<command>` (ran: <result>)
- Uncommitted: <files> | none

## Next step
<the very next action and who takes it>

## In flight / tried and ruled out
- <failing test, 3-5 lines of output; each attempt → why it failed; next rung: debugger | council>

## Decisions & why
- <decision the user made or the code embodies> — <reason>

## Gotchas
- <traps found; ones that will outlive the feature: propose adding them to the project CLAUDE.md>

## Open questions for the user
- ...
```

Report one line — `HANDOFF.md: T2 · red · следующий шаг: <…>` — and stop. Do not clear the TDD phase.
