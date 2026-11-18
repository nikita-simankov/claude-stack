---
type: regex
arm: both
target: { source: file, path: pricing/discount.go }
flags: i
pattern: 'coupon|loyal|tier'
match: not_contains
---
