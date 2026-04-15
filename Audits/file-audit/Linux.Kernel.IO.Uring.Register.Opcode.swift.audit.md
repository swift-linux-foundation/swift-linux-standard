# Audit: Linux.Kernel.IO.Uring.Register.Opcode.swift

## Summary

RawRepresentable struct for register opcodes. Type shell only; values live in per-resource files.

## Findings

| Rule | Status | Detail |
|------|--------|--------|
| [API-NAME-001] | PASS | `Kernel.IO.Uring.Register.Opcode` -- proper Nest.Name |
| [API-NAME-002] | PASS | No compound identifiers |
| [API-IMPL-005] | PASS | Single type declaration (`Opcode`) |
| [API-IMPL-008] | PASS | Minimal body: `rawValue` + `init` only |
| [IMPL-002] | OBSERVATION | `rawValue: UInt32` public via `RawRepresentable`. Acceptable for L2 spec layer. |
| [IMPL-006] | PASS | Typed as `UInt32` |
| [IMPL-COMPILE] | PASS | Type safety via distinct struct |

## Design Assessment

The `Opcode` struct is a passive carrier passed to the raw `register()` syscall. Type safety comes from the per-resource grouping structs (`Buffers`, `Files`, etc.) that produce `Opcode` values. This is correct L2 layering -- typed wrappers that avoid raw integer math at call sites belong at L3.

## Doc Comments

Present and thorough with usage example and see-also links.
