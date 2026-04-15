# Audit: Linux.Kernel.IO.Uring.Write.swift

## Findings

| # | Rule | Severity | Finding |
|---|------|----------|---------|
| 1 | [API-NAME-002] | **Major** | `vectoredFixed` is a compound identifier. Same structural issue as Read.swift. The WHY comment acknowledges and defers. |
| 2 | [API-IMPL-005] | Pass | Single type `Kernel.IO.Uring.Write` per file. |
| 3 | [API-NAME-001] | Pass | `Kernel.IO.Uring.Write` follows Nest.Name. |
| 4 | [API-NAME-003] | Pass | Opcode values match kernel `IORING_OP_WRITE` (23), `IORING_OP_WRITEV` (2), `IORING_OP_WRITE_FIXED` (5), `IORING_OP_WRITEV_FIXED` (61). |
| 5 | Imports | **Minor** | Same unused imports as Read.swift. Only `Kernel_IO_Primitives` is needed. |
