---
type: regex
arm: both
target: { source: file, path: pricing/discount.go }
pattern: 'if percent < 0 \|\| percent > 100 \{\n\t\treturn 0, ErrInvalidPercent\n\t\}\n\treturn price - price\*int64\(percent\)/100, nil\n\}\n$'
---
