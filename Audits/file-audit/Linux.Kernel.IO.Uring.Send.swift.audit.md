# Audit: Linux.Kernel.IO.Uring.Send.swift

## Findings

| # | Rule | Severity | Finding |
|---|------|----------|---------|
| 1 | Duplication | **Major** | `Send.standard` (rawValue 26) duplicates `Socket.send` (rawValue 26). `Send.message` (rawValue 9) duplicates `Socket.sendMessage` (rawValue 9). These are the same kernel opcodes (`IORING_OP_SEND`, `IORING_OP_SENDMSG`) exposed in two different namespaces. Violates single-source-of-truth. |
| 2 | [API-IMPL-005] | Pass | Single type `Kernel.IO.Uring.Send` per file. |
| 3 | [API-NAME-001] | Pass | `Kernel.IO.Uring.Send` follows Nest.Name. |
| 4 | [API-NAME-003] | Pass | Opcode values correct: `IORING_OP_SEND` (26), `IORING_OP_SENDMSG` (9). |
| 5 | Imports | **Minor** | Unused imports: `Kernel_Descriptor_Primitives`, `Kernel_Error_Primitives`, `Kernel_Memory_Primitives`, `Kernel_File_Primitives`. |
| 6 | Design | **Question** | Send namespace serves primarily as a gateway to `Send.Zero`. The `standard` and `message` opcodes are already available as `Socket.send` and `Socket.sendMessage`. Is the duplication intentional for the call-site path `.send.standard` vs `.socket.send`? |
