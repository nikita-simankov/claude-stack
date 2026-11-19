---
type: llm
---

PASS if the reported review flags that `percent >= 100` rejects a 100% discount although the spec allows 0..100 (AC2: only below 0 or above 100 is invalid), and notes the tests do not cover the 100 boundary.
FAIL if this boundary bug is not reported.
