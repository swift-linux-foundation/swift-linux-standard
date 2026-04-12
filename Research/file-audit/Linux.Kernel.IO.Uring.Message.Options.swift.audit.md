# Audit: Linux.Kernel.IO.Uring.Message.Options.swift

## Findings

| # | Rule | Severity | Finding |
|---|------|----------|---------|
| 1 | [API-IMPL-005] | **Major** | File contains two types: `Kernel.IO.Uring.Message` (struct, line 22) and `Kernel.IO.Uring.Message.Options` (OptionSet, line 23). The `Message` namespace should be in its own file `Linux.Kernel.IO.Uring.Message.swift`. |
| 2 | [API-NAME-002] | **Minor** | `cqeSkip` and `flagsPass` (lines 32, 35) are compound identifiers. Consider `.cqe.skip` and `.flags.pass` via nested types, or accept as spec-mirroring of `IORING_MSG_RING_CQE_SKIP` / `IORING_MSG_RING_FLAGS_PASS`. |
| 3 | Design | **Minor** | `Message` is declared as a `struct` but has no stored properties and no initializer -- it is purely a namespace. Should be `enum Message` to prevent instantiation. |
| 4 | Missing opcode | **Minor** | No `Message` opcode reference. The `MSG_RING` opcode (40) lives in `Opcode.Ring.msg` but there is no cross-reference from the `Message` namespace to it. |
| 5 | [API-NAME-001] | Pass | `Kernel.IO.Uring.Message.Options` follows Nest.Name. |
| 6 | [API-NAME-003] | Pass | Uses `IORING_MSG_RING_CQE_SKIP` and `IORING_MSG_RING_FLAGS_PASS` from kernel header. Correct. |
