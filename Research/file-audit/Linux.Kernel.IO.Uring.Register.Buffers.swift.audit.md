# Audit: Linux.Kernel.IO.Uring.Register.Buffers.swift

## Summary

Groups buffer register/unregister opcodes. Uses metatype accessor pattern.

## Findings

| Rule | Status | Detail |
|------|--------|--------|
| [API-NAME-001] | PASS | `Kernel.IO.Uring.Register.Buffers` -- proper Nest.Name |
| [API-NAME-002] | PASS | No compound identifiers |
| [API-IMPL-005] | DEFECT | File contains TWO type-level declarations: `struct Buffers` (extension on `Register`) AND a computed property extension on `Register.Opcode`. The Opcode extension should be in a separate file or consolidated into the Opcode file. |
| [API-IMPL-008] | PASS | Minimal body -- static members only |
| [IMPL-006] | PASS | All members typed as `Opcode` |
| [IMPL-COMPILE] | PASS | |

## Metatype Accessor Pattern

```swift
public static var buffers: Kernel.IO.Uring.Register.Buffers.Type { ... }
```

This returns the metatype to enable `.buffers.register` syntax. It works but is unusual -- Swift developers expect value/instance access, not metatype access. A nested enum `Opcode.Buffers` with static members would be more conventional and avoid the `.Type` return.

## Missing Opcodes

- `IORING_REGISTER_BUFFERS2` (15) -- tagged buffer registration (kernel 5.13+)
- `IORING_UNREGISTER_BUFFERS2` (16) -- tagged buffer unregistration

## Doc Comments

Present. Brief but adequate.
