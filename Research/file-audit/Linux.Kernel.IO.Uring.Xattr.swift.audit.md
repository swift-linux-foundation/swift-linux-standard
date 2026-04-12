# Audit: Linux.Kernel.IO.Uring.Xattr.swift

## Findings

| # | Rule | Severity | Finding |
|---|------|----------|---------|
| 1 | [API-NAME-003] | **Minor** | `fset` and `fget` (lines 23, 29) mirror `IORING_OP_FSETXATTR` / `IORING_OP_FGETXATTR` but the `f` prefix is C-speak for "file descriptor variant". Consider `Xattr.File.set`/`Xattr.File.get` vs `Xattr.set`/`Xattr.get` decomposition for clarity. However, the kernel names are `fsetxattr`/`fgetxattr` so this is spec-mirroring. Acceptable. |
| 2 | [API-IMPL-005] | Pass | Single type `Kernel.IO.Uring.Xattr` per file. |
| 3 | [API-NAME-001] | Pass | `Kernel.IO.Uring.Xattr` follows Nest.Name. |
| 4 | [API-NAME-003] | Pass | Opcode values correct: `IORING_OP_FSETXATTR` (41), `IORING_OP_SETXATTR` (42), `IORING_OP_FGETXATTR` (43), `IORING_OP_GETXATTR` (44). |
| 5 | Imports | **Minor** | Unused imports. Only `Kernel_IO_Primitives` is needed. |
