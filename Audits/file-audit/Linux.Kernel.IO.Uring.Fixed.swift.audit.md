# Audit: Linux.Kernel.IO.Uring.Fixed.swift

## Findings

| # | Rule | Severity | Finding |
|---|------|----------|---------|
| 1 | [API-NAME-002] | **Major** | `fdInstall` (line 23) is a compound identifier. Should be decomposed. The kernel constant is `IORING_OP_FIXED_FD_INSTALL`; a nested path like `Fixed.Descriptor.install` or just `Fixed.install` would avoid the compound. |
| 2 | [API-IMPL-005] | Pass | Single type `Kernel.IO.Uring.Fixed` per file. |
| 3 | [API-NAME-001] | Pass | `Kernel.IO.Uring.Fixed` follows Nest.Name. |
| 4 | [API-NAME-003] | Pass | Opcode value correct: `IORING_OP_FIXED_FD_INSTALL` (54). |
| 5 | Imports | **Minor** | Unused imports. Only `Kernel_IO_Primitives` is needed. |
