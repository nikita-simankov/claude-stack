---
type: llm
focus: { source: file, path: HANDOFF.md }
---

PASS if the handoff lets a fresh session continue without this conversation: it states the task (T2, discount spec), the TDD phase (RED, test written, awaiting the user's review), that the test currently fails and the command to run it, and the very next step is that the user reviews/approves the RED test before GREEN.
FAIL if it claims the test was approved, says the next step is implementing GREEN without approval, omits the phase, or gives no command.
