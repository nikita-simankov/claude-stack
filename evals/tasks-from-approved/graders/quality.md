---
type: llm
focus: { source: file, path: docs/specs/coupons/tasks.md }
---

PASS if every task is one small behaviour with concrete test cases (inputs and expected outputs), names the test file and production file, and the tasks are ordered so nothing depends on a later task.
FAIL if a task bundles several behaviours, a task has no concrete test cases, or a task like "refactor"/"polish"/"write all tests" appears.
