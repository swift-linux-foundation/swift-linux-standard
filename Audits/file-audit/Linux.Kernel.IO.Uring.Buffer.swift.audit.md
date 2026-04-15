# Audit: Linux.Kernel.IO.Uring.Buffer.swift

## Summary

`enum Buffer` serving dual purpose: namespace for buffer-related types AND opcode provider for buffer operations.

## Findings

| ID | Status | Finding |
|----|--------|---------|
| [API-NAME-001] | PASS | `Kernel.IO.Uring.Buffer` -- proper Nest.Name |
| [API-NAME-003] | PASS | Maps `IORING_OP_PROVIDE_BUFFERS` (31) and `IORING_OP_REMOVE_BUFFERS` (32) |
| [API-IMPL-005] | VIOLATION | File contains `enum Buffer` with opcode statics AND the metatype accessor `static var buffer` on Opcode. Two concerns in one file. The namespace definition belongs here; the opcode accessor belongs with the Opcode type or in a dedicated bridge file. |
| [API-IMPL-008] | PASS | Minimal: two static lets plus namespace purpose |
| [IMPL-002] | N/A | Opcodes are accessed through typed Opcode, not raw values |
| [IMPL-006] | N/A | No stored properties |
| [IMPL-064] | N/A | Never instantiated |

## Issues

1. **Dual-purpose type**: Buffer serves as both a namespace (`Buffer.Index`, `Buffer.Group`) and an opcode provider (`Buffer.provide`, `Buffer.remove`). This conflates two concerns. The opcode sub-namespace pattern used by Read, Write, Socket etc. declares a struct with only opcode statics. Buffer is an enum that serves as both a namespace for child types AND an opcode carrier. The inconsistency is that Read/Write/Socket are structs (opcode-only), while Buffer is an enum (namespace + opcodes).

   Consider: Should Buffer be split into `enum Buffer {}` (pure namespace for Index/Group) and a separate opcode sub-namespace? Or should the opcodes move to a `Buffer.Opcode` nested type?

   Counterargument: The current pattern works and the enum-with-statics is functionally identical to struct-with-statics for this use case.

2. **`.provide` and `.remove` naming**: These mirror `IORING_OP_PROVIDE_BUFFERS` and `IORING_OP_REMOVE_BUFFERS`. The spec uses plural "BUFFERS" but the Swift names are `provide`/`remove` (verbs without noun). Acceptable -- the noun is implied by the namespace (`Buffer.provide` reads as "buffer provide").

## Verdict

Functional but structurally inconsistent with other opcode sub-namespaces. The dual namespace/opcode role is the main concern.
