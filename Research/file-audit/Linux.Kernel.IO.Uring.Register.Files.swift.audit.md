# Audit: Linux.Kernel.IO.Uring.Register.Files.swift

## Summary

Groups file register/unregister/update opcodes. Same metatype pattern as Buffers.

## Findings

| Rule | Status | Detail |
|------|--------|--------|
| [API-NAME-001] | PASS | `Kernel.IO.Uring.Register.Files` -- proper Nest.Name |
| [API-NAME-002] | PASS | No compound identifiers |
| [API-IMPL-005] | DEFECT | Two type-level declarations in one file (struct Files + Opcode extension) |
| [API-IMPL-008] | PASS | Minimal body |
| [IMPL-006] | PASS | All `Opcode` typed |
| [IMPL-COMPILE] | PASS | |

## Missing Opcodes

- `IORING_REGISTER_FILES2` (13) -- tagged file registration (kernel 5.13+)
- `IORING_REGISTER_FILES_UPDATE2` (14) -- tagged file update

## Doc Comments

Present. Accurate.
