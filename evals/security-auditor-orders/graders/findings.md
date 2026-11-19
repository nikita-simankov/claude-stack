---
type: llm
---

PASS if the reported audit flags BOTH (1) SQL injection via string concatenation of the id query parameter, with a parameterized query as the fix, and (2) missing ownership check (IDOR): any authenticated user can read any order because user_id is never compared to the caller (X-User-ID), with a fix that scopes the query to the caller. Mentioning the leaked err.Error() is a bonus, not required.
FAIL if either the injection or the IDOR is missing.
