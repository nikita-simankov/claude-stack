---
type: llm
---

PASS if the final reply states that the tests pass and names the command that was run (for example `go test ./...`), and does not claim anything was verified that was not run.
FAIL if the reply claims success without naming a command that was run, or reports failing tests as done.
