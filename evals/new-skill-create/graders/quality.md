---
type: llm
---

PASS if the reply reports a new skill under skills/<name>/SKILL.md whose frontmatter has a third-person description and when_to_use with triggers, that reuses the stack's scripts (feature-base.sh) rather than re-implementing them, keeps git read-only, adds at least one eval case for it (or explicitly says why not), and reports that scripts/validate.sh was run with its result.
FAIL if it does not mention running validation, writes git-write commands into the skill, or creates no eval and gives no reason.
