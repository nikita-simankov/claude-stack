---
name: new-skill
description: Extend this Claude Code stack with a new skill, subagent, hook or output style that matches its conventions. Use when the user says "new skill", "новый навык", "добавь агента", "добавь хук", "расширь стек", or describes a repeatable workflow worth packaging.
argument-hint: "<skill|agent|hook> <what it should do>"
---

# new-skill

Work inside the claude-stack repository (the plugin root has `.claude-plugin/plugin.json`).

## Decide the component
- **Skill** (`skills/<name>/SKILL.md`): a repeatable procedure or body of knowledge Claude follows in the main context.
- **Subagent** (`agents/<name>.md`): a specialist that works in its own context and returns a summary; use when the work is read-heavy or needs an independent view.
- **Hook** (`hooks/hooks.json` + `hooks/scripts/*.sh`): something that must *always* happen or *never* happen, regardless of what the model decides.
- Prefer extending an existing skill over adding a near-duplicate. Say so if the request duplicates something.

## Conventions
- Names: kebab-case, short, a verb or noun the user would type.
- `description`: what it does + **when** to use it + trigger phrases in Russian and English. This string is what routing matches against; be specific.
- Body in English, imperative, numbered steps, a fixed report format at the end. Reports to the user are in Russian and short.
- Respect the stack rules: no git writes, strict TDD, no test cheating, escalation ladder.
- Skill files ≤ ~150 lines; move long reference material into `references/*.md` and link it.
- Agents: frontmatter `name`, `description`, `tools` (least privilege; reviewers are read-only), `model` (`opus` for judgement-heavy, `sonnet` for routine, `haiku` for cheap lookups). Body: role, process, output format.
- Hook scripts: bash, `set -euo pipefail`, read JSON from stdin with `jq`, exit 2 + stderr message to block, exit 0 otherwise. Fail open with a warning if `jq` is missing.

## Finish
1. Run `scripts/validate.sh`.
2. Add the component to the tables in `README.md` and `CLAUDE.md` (subagents).
3. Report the files created and how to invoke the component.
