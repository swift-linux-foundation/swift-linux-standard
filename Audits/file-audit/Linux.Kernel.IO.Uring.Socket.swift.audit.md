# Audit: Linux.Kernel.IO.Uring.Socket.swift

## Findings

| # | Rule | Severity | Finding |
|---|------|----------|---------|
| 1 | [API-NAME-002] | **Major** | `sendMessage` (line 35), `receiveMessage` (line 38), `receiveZeroCopy` (line 56) are compound identifiers. Should be decomposed: `.send.message`, `.receive.message`, `.receive.zero.copy` via nested namespaces. The WHY comment on `receiveZeroCopy` acknowledges this. |
| 2 | Duplication | **Major** | `Socket.send` (26) duplicates `Send.standard` (26). `Socket.sendMessage` (9) duplicates `Send.message` (9). Same kernel opcodes in two namespaces. |
| 3 | [API-IMPL-005] | Pass | Single type `Kernel.IO.Uring.Socket` per file. |
| 4 | [API-NAME-001] | Pass | `Kernel.IO.Uring.Socket` follows Nest.Name. |
| 5 | [API-NAME-003] | Pass | All opcode values match kernel constants: `IORING_OP_ACCEPT` (13), `IORING_OP_CONNECT` (16), `IORING_OP_SEND` (26), `IORING_OP_RECV` (27), `IORING_OP_SENDMSG` (9), `IORING_OP_RECVMSG` (10), `IORING_OP_SHUTDOWN` (34), `IORING_OP_SOCKET` (45), `IORING_OP_BIND` (56), `IORING_OP_LISTEN` (57), `IORING_OP_RECV_ZC` (58). |
| 6 | Imports | **Minor** | Unused imports: `Kernel_Descriptor_Primitives`, `Kernel_Error_Primitives`, `Kernel_Memory_Primitives`, `Kernel_File_Primitives`. |
| 7 | Missing | **Minor** | No `Socket.Options` type for accept flags (`IORING_ACCEPT_MULTISHOT`, `IORING_ACCEPT_DONTWAIT`, etc.), though these may live elsewhere. |
