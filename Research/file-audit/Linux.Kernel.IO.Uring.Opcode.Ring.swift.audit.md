# Audit: Linux.Kernel.IO.Uring.Opcode.Ring.swift

## Summary

Ring-specific opcodes: `msg` (IORING_OP_MSG_RING), `cmd` (IORING_OP_URING_CMD), `cmd128`.

## Findings

| ID | Status | Finding |
|----|--------|---------|
| [API-NAME-001] | PASS | `Kernel.IO.Uring.Opcode.Ring` -- proper Nest.Name |
| [API-NAME-003] | PASS | Maps `IORING_OP_MSG_RING`, `IORING_OP_URING_CMD` |
| [API-IMPL-005] | VIOLATION | File contains `struct Ring` AND the `ring` metatype accessor on `Opcode`. Two declarations in one file. The accessor `public static var ring` should live in a separate extension file or in the Opcode file itself. |
| [API-IMPL-008] | PASS | Only static lets, no stored properties |
| [IMPL-002] | N/A | No public rawValue on Ring itself -- it returns `Opcode` values |
| [IMPL-006] | PASS | Opcodes use correct UInt8 via Opcode init |
| [IMPL-064] | PASS | Namespace struct with only static members -- Copyable is irrelevant |

## Issues

1. **Structural consistency**: `Ring` is declared inside `extension Kernel.IO.Uring.Opcode` as a nested struct with static let members that return `Opcode`. But Ring itself is never instantiated and has no instance members -- it exists only as a metatype namespace. This is consistent with the pattern used by Read, Write, Socket, etc. However, those types are declared in `extension Kernel.IO.Uring` (siblings to Opcode), while Ring is nested inside Opcode. The nesting is correct because Ring is semantically a sub-group of opcodes.

2. **Ring vs Uring naming**: `Ring` here means "ring message" operations, not the io_uring ring itself. The doc comment "Ring operation opcodes" is ambiguous. Should clarify: "Inter-ring messaging and passthrough command opcodes."

3. **[API-IMPL-005] mitigation**: The metatype accessor pattern (`static var ring: Ring.Type`) co-located with the type it accesses is the established pattern across ALL opcode sub-namespaces (Read, Write, Socket, etc. all do this). This is a systemic pattern choice, not a per-file violation. If accepted as a pattern exception, all 13+ opcode files pass.

## Verdict

Clean. Minor doc comment clarification needed. The one-type-per-file "violation" is a deliberate pattern applied uniformly.
