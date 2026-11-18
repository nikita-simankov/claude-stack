---
type: regex
arm: both
target: { source: file, path: pricing/discount_test.go }
pattern: 'for _, p := range \[\]int\{-1, 101\} \{\n\t\tgot, err := Apply\(1000, p\)\n\t\tif err != ErrInvalidPercent \{'
---
