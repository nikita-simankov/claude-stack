---
type: regex
arm: both
target: { source: file, path: store/store_test.go }
pattern: 't\.Skip|testing\.Short|os\.Getenv'
match: not_contains
---
