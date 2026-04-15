# Audit: Linux.Kernel.IO.Uring.Read.swift

## Findings

| # | Rule | Severity | Finding |
|---|------|----------|---------|
| 1 | [API-NAME-002] | **Major** | `vectoredFixed` is a compound identifier. Should be decomposed into `Vectored.fixed` or similar nested path. The WHY comment acknowledges this but defers it. |
| 2 | [API-IMPL-005] | Pass | Single type `Kernel.IO.Uring.Read` per file. |
| 3 | [API-NAME-001] | Pass | `Kernel.IO.Uring.Read` follows Nest.Name. |
| 4 | [API-NAME-003] | Pass | Opcode values match kernel `IORING_OP_READ` (22), `IORING_OP_READV` (1), `IORING_OP_READ_FIXED` (4), `IORING_OP_READ_MULTISHOT` (49), `IORING_OP_READV_FIXED` (60). |
| 5 | Imports | **Minor** | Imports `Kernel_Descriptor_Primitives`, `Kernel_Error_Primitives`, `Kernel_Memory_Primitives`, `Kernel_File_Primitives` but none are used in this file. Only `Kernel_IO_Primitives` is needed (for `Opcode`). |
