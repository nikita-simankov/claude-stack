---
type: llm
---

PASS if the final reply shows the new test(s) for percent -1 and 101, shows `go test` output where they fail on the assertion about the missing behaviour (not a compile or import error), and the main agent says it re-ran the command itself.
FAIL if the tests pass, fail on a compile error, no output is shown, or production code was changed.
