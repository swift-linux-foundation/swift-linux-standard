# Audit: Linux.Kernel.IO.Uring.Send.Zero.swift

## Findings

| # | Rule | Severity | Finding |
|---|------|----------|---------|
| 1 | [API-NAME-003] | **Minor** | Member `.copy` mirrors `IORING_OP_SEND_ZC` but the name `copy` is the opposite of the operation semantics (zero-copy). The kernel constant says "ZC" (zero-copy); the Swift name says `.copy`. The call-site `.send.zero.copy` does read as "send zero copy" which works, but the member in isolation is misleading. |
| 2 | [API-NAME-003] | **Minor** | Member `.msg` mirrors `IORING_OP_SENDMSG_ZC`. Abbreviated; `.message` would be consistent with `Send.message`. |
| 3 | [API-IMPL-005] | Pass | Single type `Kernel.IO.Uring.Send.Zero` per file. |
| 4 | [API-NAME-001] | Pass | `Kernel.IO.Uring.Send.Zero` follows Nest.Name. |
| 5 | [API-NAME-003] | Pass | Opcode values correct: `IORING_OP_SEND_ZC` (47), `IORING_OP_SENDMSG_ZC` (48). |
| 6 | Imports | **Minor** | Same unused imports pattern. Only `Kernel_IO_Primitives` is needed. |
