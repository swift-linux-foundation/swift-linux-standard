# Audit: Linux.Kernel.IO.Uring.Opcode.swift

## Summary

Main Opcode type: `RawRepresentable` struct over `UInt8`. Serves as the central discriminator for all io_uring operations.

## Findings

| ID | Status | Finding |
|----|--------|---------|
| [API-NAME-001] | PASS | `Kernel.IO.Uring.Opcode` -- proper Nest.Name |
| [API-NAME-003] | PASS | Mirrors `IORING_OP_*` from `<linux/io_uring.h>` |
| [API-IMPL-005] | PASS | Single type declaration in file |
| [API-IMPL-008] | PASS | Minimal body: rawValue + init only |
| [IMPL-002] | QUESTION | `rawValue` is public via `RawRepresentable`. Acceptable at L2 since this IS the specification encoding -- consumers need raw values for SQE population. However, consider whether the sub-namespace pattern (`.read.standard`) makes `RawRepresentable` conformance redundant for call-site use. |
| [IMPL-006] | PASS | `UInt8` matches kernel ABI width |
| [IMPL-064] | PASS | Opcode is a value identifier -- Copyable is correct |

## Protocol Conformances

- Has: `RawRepresentable`, `Sendable`, `Equatable`, `Hashable`, `CustomStringConvertible`
- Missing: `Comparable` -- opcodes have no meaningful ordering, omission is correct.

## Issues

1. **`let` vs `var` for rawValue**: `rawValue` is `let`, which is correct for an immutable identifier.

2. **CustomStringConvertible exhaustiveness**: The `description` switch references all sub-namespace opcodes (`.read.standard`, `.socket.accept`, etc.) but these go through the metatype accessor pattern. If a sub-namespace adds an opcode without updating this switch, the `default` case silently catches it. No compile-time exhaustiveness check is possible since Opcode is not an enum. This is inherent to the design -- acceptable.

3. **Duplicate opcode values in description**: `Socket.send` (rawValue 26) and `Send.standard` (rawValue 26) are the same kernel opcode (`IORING_OP_SEND`). Similarly `Socket.sendMessage` (rawValue 9) and `Send.message` (rawValue 9) are `IORING_OP_SENDMSG`. The switch matches the first case encountered. This duplication is a semantic concern -- see Opcode.Ring audit.

## Verdict

Structurally sound. The metatype accessor pattern for sub-namespaces (`.read.standard`) is well-executed. One area to watch: the rawValue duplication across Socket and Send namespaces.
