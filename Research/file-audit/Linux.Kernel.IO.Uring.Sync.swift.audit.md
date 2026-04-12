# Audit: Linux.Kernel.IO.Uring.Sync.swift

## Findings

| # | Rule | Severity | Finding |
|---|------|----------|---------|
| 1 | [API-NAME-002] | **Major** | `fileRange` (line 26) is a compound identifier. Should be decomposed: `.file.range` or nested `Sync.File.range` to follow Nest.Name decomposition rules. |
| 2 | [API-IMPL-005] | Pass | Single type `Kernel.IO.Uring.Sync` per file. |
| 3 | [API-NAME-003] | Pass | Opcode values correct: `IORING_OP_FSYNC` (3), `IORING_OP_SYNC_FILE_RANGE` (8). |
| 4 | Imports | **Minor** | Unused imports. Only `Kernel_IO_Primitives` is needed. |
