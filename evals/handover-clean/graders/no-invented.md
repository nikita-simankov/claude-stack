---
type: llm
---

The diff under review is a clean, correct implementation of T2 with a table-driven test.
PASS if the final reply says the diff is fine / ready (possibly with minor optional remarks clearly marked as optional) and names checks that were run (e.g. go test, go vet).
FAIL if the reply reports a blocking problem that does not exist, or claims checks passed without naming a command that was run.
