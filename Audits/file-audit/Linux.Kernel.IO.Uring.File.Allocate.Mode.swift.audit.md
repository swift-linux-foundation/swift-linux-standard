# Audit: Linux.Kernel.IO.Uring.File.Allocate.Mode.swift

## Findings

| # | Rule | Severity | Finding |
|---|------|----------|---------|
| 1 | [API-IMPL-005] | **Major** | File contains two types: `Kernel.IO.Uring.File.Allocate` (empty namespace enum, line 42) and `Kernel.IO.Uring.File.Allocate.Mode` (enum with cases, line 43). The `Allocate` namespace should be in its own file `Linux.Kernel.IO.Uring.File.Allocate.swift`. |
| 2 | [IMPL-002] | **Minor** | `rawBits` (line 69) exposes `Int32` which is a raw C type leaking into the internal API. Should use a dedicated type or at minimum be `@usableFromInline` only (which it is -- acceptable for internal). |
| 3 | [API-NAME-001] | Pass | `Kernel.IO.Uring.File.Allocate.Mode` follows Nest.Name. |
| 4 | [API-NAME-003] | Pass | Uses `FALLOC_FL_KEEP_SIZE`, `FALLOC_FL_PUNCH_HOLE`, `FALLOC_FL_COLLAPSE_RANGE`, `FALLOC_FL_ZERO_RANGE`, `FALLOC_FL_INSERT_RANGE`, `FALLOC_FL_UNSHARE_RANGE` from kernel header. All correct. |
| 5 | Completeness | Pass | All six fallocate modes from `<linux/falloc.h>` are covered. |
| 6 | Doc | Pass | Excellent table-format documentation showing mode/effect/keepSize. |
