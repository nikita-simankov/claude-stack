---
name: tasks
description: Break an approved spec into small ordered implementation tasks, each with concrete test cases. Use after a spec is approved, or when the user says "tasks", "разбей на задачи", "план реализации". Writes docs/specs/<feature>/tasks.md.
argument-hint: "<feature folder under docs/specs/>"
---

# tasks

Input: `docs/specs/<feature>/spec.md` with `Status: approved`. If it is not approved, say so and stop.

## Rules for tasks
- Each task is one TDD cycle: 15-60 minutes of work, one behaviour, one reason to fail.
- Order by dependency, then by risk: the riskiest unknown goes first so it fails early.
- Each task lists **test cases** with concrete inputs and expected outputs, traced to acceptance criteria (`AC1`, `AC2`...). Every AC must be covered by at least one task.
- Name the test file and the production file(s) each task will touch.
- Data/migration tasks come before code that depends on them.
- No task named "refactor everything" or "polish": refactoring happens inside each cycle.

## Output: `docs/specs/<feature>/tasks.md`

```markdown
# Tasks: <Feature>

Spec: ./spec.md

- [ ] T1. <behaviour in one line>  (AC1)
  - Files: `src/server/foo.ts`, test `src/server/foo.test.ts`
  - Tests:
    - returns X when Y
    - throws NotFound when id is unknown
- [ ] T2. ...
```

Status markers: `[ ]` todo, `[~]` in progress, `[x]` done.

Finish by showing the task list and the AC coverage. Wait for approval, then suggest `tdd` on T1.
