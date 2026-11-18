---
type: regex
arm: both
target: { source: file, path: pricing/cheapest.go }
pattern: 'sync\.(Mutex|RWMutex)'
match: not_contains
---
