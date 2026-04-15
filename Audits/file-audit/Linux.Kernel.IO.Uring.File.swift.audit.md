# Audit: Linux.Kernel.IO.Uring.File.swift

## Findings

| # | Rule | Severity | Finding |
|---|------|----------|---------|
| 1 | [API-NAME-002] | **Major** | `filesUpdate` (line 56) is a compound identifier. Should be decomposed. |
| 2 | [API-NAME-003] | **Minor** | Members use raw syscall names (`openat`, `openat2`, `statx`, `fallocate`, `fadvise`, `ftruncate`, `renameat`, `unlinkat`, `mkdirat`, `symlinkat`, `linkat`). This is valid spec-mirroring of POSIX/Linux syscall names, but creates inconsistency with other namespaces that use semantic names (e.g., `Socket.accept` not `Socket.accept4`). Consider whether `open`, `stat`, `allocate`, `advise`, `truncate`, `rename`, `unlink`, `mkdir`, `symlink`, `link` would be clearer while preserving the at-dirfd variants via a separate parameter. |
| 3 | [API-IMPL-005] | Pass | Single type `Kernel.IO.Uring.File` per file. |
| 4 | [API-NAME-001] | Pass | `Kernel.IO.Uring.File` follows Nest.Name. |
| 5 | [API-NAME-003] | Pass | Opcode values correct: `IORING_OP_OPENAT` (18), `IORING_OP_OPENAT2` (28), `IORING_OP_STATX` (21), `IORING_OP_FALLOCATE` (17), `IORING_OP_FADVISE` (24), `IORING_OP_FTRUNCATE` (55), `IORING_OP_RENAMEAT` (35), `IORING_OP_UNLINKAT` (36), `IORING_OP_MKDIRAT` (37), `IORING_OP_SYMLINKAT` (38), `IORING_OP_LINKAT` (39), `IORING_OP_FILES_UPDATE` (20). |
| 6 | Imports | **Minor** | Unused imports. Only `Kernel_IO_Primitives` is needed. |
