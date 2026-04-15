# Audit: Linux.Kernel.IO.Uring.Register.Eventfd.swift

## Summary

Groups eventfd register/unregister/async opcodes. Same metatype pattern.

## Findings

| Rule | Status | Detail |
|------|--------|--------|
| [API-NAME-001] | PASS | `Kernel.IO.Uring.Register.Eventfd` -- proper Nest.Name |
| [API-NAME-002] | PASS | No compound identifiers |
| [API-IMPL-005] | DEFECT | Two type-level declarations in one file (struct Eventfd + Opcode extension) |
| [API-IMPL-008] | PASS | Minimal body |
| [IMPL-006] | PASS | All `Opcode` typed |
| [IMPL-COMPILE] | PASS | |

## Naming

`.async` as a member name -- not a keyword collision in static context. Safe.

## Doc Comments

Present. `.async` doc clearly distinguishes async-only signaling from full signaling.
