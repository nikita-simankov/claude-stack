---
type: regex
arm: both
target: { source: file, path: pricing/discount.go }
pattern: 'percent\s*(<|>|<=|>=)|(<|>|<=|>=)\s*percent|return 0, ErrInvalidPercent'
match: not_contains
---
