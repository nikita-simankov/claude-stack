---
name: council
description: Convene a council of independent subagents with different roles to break a deadlock, then synthesize one verdict. Use when stuck after the debugger subagent failed, when a hard design decision has no clear winner, or when the user says "council", "консилиум", "собери консилиум". Default 5 roles; the user can pass a number up to 10.
argument-hint: "[N roles, default 5] <problem>"
---

# council

Independent perspectives, then one decision. Not ten copies of the same opinion.

## 1. Brief
Write one shared brief (the members do not see this conversation):
- the problem and the goal;
- facts: errors, logs, repro, constraints;
- what was already tried and the result of each attempt;
- relevant file paths;
- the exact question to answer.

## 2. Members
Launch the members **in parallel** as subagents (general-purpose, or the matching specialist agent where one exists). Each gets the brief plus its role. Default 5, in this order; for N>5 add from the extended list.

| # | Role | Lens |
|---|---|---|
| 1 | Skeptic | Assume the obvious explanation is wrong. What evidence contradicts the current theory? |
| 2 | Architect (`architect`) | Is the problem a symptom of a design flaw? What structural change removes it? |
| 3 | Data & state pedant | Trace actual data, types, nulls, encodings, transactions, cache, concurrency step by step |
| 4 | Environment investigator | Versions, config, env vars, build/runtime differences, Docker, network, OS |
| 5 | Minimalist | Simplest possible fix or workaround; what can be deleted instead of added? |
| 6 | Security (`security-auditor`) | Does any candidate fix open a hole? |
| 7 | Performance | Timing, load, resource limits, N+1, locks |
| 8 | Historian | `git log`/blame: when did it start, which change introduced it? |
| 9 | Tester (`test-writer`) | What test would pin this down? Is the existing test itself wrong? |
| 10 | Outsider (`researcher`) | Known issues, changelogs, upstream bugs, docs for the exact versions |

Each member must return: **diagnosis**, **evidence** (file:line, output), **recommended action**, **confidence 0-100%**, **what would prove them wrong**. Read-only investigation unless the brief says otherwise.

## 3. Synthesis
You are the chair. Do not average opinions:
- group members by diagnosis; weigh evidence over confidence;
- name disagreements explicitly and what experiment would settle them;
- pick one plan.

## Output
```
Вердикт: <diagnosis + plan, 2-3 lines>
Консенсус: <who agrees, on what>
Расхождения: <who disagrees + deciding experiment>
Следующий шаг: <one concrete action>
```
Then stop and wait for the user unless the next step is a read-only experiment.
