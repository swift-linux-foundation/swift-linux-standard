# Audit: Linux.Kernel.IO.Uring.Futex.swift

## Findings

| # | Rule | Severity | Finding |
|---|------|----------|---------|
| 1 | [API-NAME-003] | **Minor** | `waitv` (line 29) mirrors `IORING_OP_FUTEX_WAITV` but abbreviates "vector". For consistency with the `Read.vectored`/`Write.vectored` pattern, consider `waitVectored` or a nested decomposition. However, `futex_waitv` is the kernel syscall name, so `waitv` is spec-mirroring. Acceptable. |
| 2 | [API-IMPL-005] | Pass | Single type `Kernel.IO.Uring.Futex` per file. |
| 3 | [API-NAME-001] | Pass | `Kernel.IO.Uring.Futex` follows Nest.Name. |
| 4 | [API-NAME-003] | Pass | Opcode values correct: `IORING_OP_FUTEX_WAIT` (51), `IORING_OP_FUTEX_WAKE` (52), `IORING_OP_FUTEX_WAITV` (53). |
| 5 | Imports | **Minor** | Unused imports. Only `Kernel_IO_Primitives` is needed. |
