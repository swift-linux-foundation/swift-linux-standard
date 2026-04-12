# Audit: Linux.Kernel.IO.Uring.Register.Rings.swift

## Summary

Ring enable opcode. Same metatype pattern.

## Findings

| Rule | Status | Detail |
|------|--------|--------|
| [API-NAME-001] | PASS | `Kernel.IO.Uring.Register.Rings` -- proper Nest.Name |
| [API-NAME-002] | PASS | No compound identifiers |
| [API-IMPL-005] | DEFECT | Two type-level declarations in one file (struct Rings + Opcode extension) |
| [API-IMPL-008] | PASS | Minimal body |
| [IMPL-006] | PASS | `Opcode` typed |
| [IMPL-COMPILE] | PASS | |

## Missing Opcodes

- `IORING_REGISTER_RING_FDS` (20) -- register ring file descriptors (kernel 5.18+)
- `IORING_UNREGISTER_RING_FDS` (21) -- unregister ring file descriptors

These are significant for the `.registeredRing` enter flag to work.

## Doc Comments

Present. Accurate. Good cross-reference to `.rDisabled` setup flag.
