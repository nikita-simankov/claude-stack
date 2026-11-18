---
name: commit-msg
description: Prepare a Conventional Commit message for the current changes without committing. Use when work is ready to commit or the user says "commit message", "сообщение коммита", "что коммитить". The user runs git themselves.
---

# commit-msg

Claude never commits. This skill produces the message and the commands for the user.

1. Read `git status`, `git diff --stat`, `git diff` (staged and unstaged).
2. If the changes contain more than one logical change, propose a split: which files/hunks go into which commit.
3. Write each message:
   - Subject: `type(scope): imperative summary`, ≤72 chars, no period. Types: feat, fix, refactor, perf, test, docs, build, ci, chore.
   - Body (when not obvious): *why* the change was made, wrapped at 72. Reference the spec/task: `Spec: docs/specs/<feature>/spec.md (T3)`.
   - `BREAKING CHANGE:` footer when the public API, schema or config contract changes.
4. Output ready-to-run commands, one block per commit:

```bash
git add <paths>
git commit -m "feat(billing): add proration for mid-cycle upgrades" -m "Spec: docs/specs/proration/spec.md (T1-T4)"
```

Flag anything that must not be committed (secrets, `.env`, large binaries, `.claude/tdd-phase`, `HANDOFF.md`).
