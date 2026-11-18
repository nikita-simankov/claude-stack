---
name: handoff
description: Write HANDOFF.md so the next session can continue without loss. Use at the end of a session, before context runs out, before a long break, or when the user says "handoff", "сохрани контекст", "запиши где остановились".
---

# handoff

Write `HANDOFF.md` in the project root (it is in the stack's recommended `.gitignore`; overwrite the previous one). Write for a reader with zero context: a fresh session of yourself.

```markdown
# Handoff · <YYYY-MM-DD HH:MM>

## Goal
<What we are building and why, 1-3 lines. Link spec/tasks.>

## State
- Branch: ...
- Task: <T#> · TDD phase: <red|green|refactor|—>
- Tests: <green/red, command to run>
- Uncommitted: <files, or "none">

## Done this session
- ...

## Next steps
1. <the very next concrete action>
2. ...

## Decisions & why
- <decision> — <reason> (so the next session does not relitigate it)

## Gotchas
- <traps found: flaky test, env quirk, misleading name, API behaviour>

## Open questions for the user
- ...
```

Keep facts, drop narrative. Verify every command you list actually works. Report the path and stop.
