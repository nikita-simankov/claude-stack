---
type: llm
---

The working tree has two unrelated changes: the T2 feature (pricing/discount.go, its test, tasks.md) and a README typo fix.
PASS if the reply proposes two separate commits (feature vs README/docs typo), each with its own `git add <paths>` and Conventional Commit message, leaves running them to the user, and does not claim it committed anything.
FAIL if it proposes a single commit for everything, or says it committed.
