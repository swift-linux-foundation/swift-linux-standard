# Audit: Linux.Kernel.IO.Uring.Cancel.swift

## Findings

| # | Rule | Severity | Finding |
|---|------|----------|---------|
| 1 | Completeness | **Major** | Missing `Cancel.Options` OptionSet. The kernel defines `IORING_ASYNC_CANCEL_ALL`, `IORING_ASYNC_CANCEL_FD`, `IORING_ASYNC_CANCEL_ANY`, `IORING_ASYNC_CANCEL_FD_FIXED`, `IORING_ASYNC_CANCEL_USERDATA`, `IORING_ASYNC_CANCEL_OP`. These flags are needed to specify cancel semantics (cancel by fd, cancel all, etc.). Without them, cancel operations cannot be fully configured. |
| 2 | [API-IMPL-005] | Pass | Single type `Kernel.IO.Uring.Cancel` per file. |
| 3 | [API-NAME-001] | Pass | `Kernel.IO.Uring.Cancel` follows Nest.Name. |
| 4 | [API-NAME-003] | Pass | Opcode value correct: `IORING_OP_ASYNC_CANCEL` (14). |
| 5 | Imports | **Minor** | Unused imports. Only `Kernel_IO_Primitives` is needed. |
